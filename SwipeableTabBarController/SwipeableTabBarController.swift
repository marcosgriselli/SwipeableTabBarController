//
//  SwipeableTabBarController.swift
//  SwipeableTabBarController
//
//  Created by Marcos Griselli on 1/26/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit 

/// `UITabBarController` subclass with a `selectedViewController` property observer,
/// `SwipeInteractor` that handles the swiping between tabs gesture, and a `SwipeTransitioningProtocol`
/// that determines the animation to be added. Use it or subclass it.
@objc(SwipeableTabBarController)
open class SwipeableTabBarController: UITabBarController {

    private enum PendingSelection {
        case index(Int, SelectionSource)
        case viewController(UIViewController, SelectionSource)
    }

    private enum SelectionSource {
        case swipe
        case tap
    }

    /// Animated transition to be performed while swiping
    public var swipeAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeTransitionAnimator()
    
    /// Animated transition to be performed when tapping on a tabbar item
    public var tapAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeTransitionAnimator() {
        didSet {
            currentAnimatedTransitioningType = tapAnimatedTransitioning
        }
    }
    
    /// Animated transition being used currently
    private var currentAnimatedTransitioningType: SwipeTransitioningProtocol?

    /// Latest selection requested while UIKit is still completing a tab transition.
    private var pendingSelection: PendingSelection?

    /// Prevents registering multiple completion handlers for the same pending selection.
    private var isPendingSelectionHandlerScheduled = false

    /// Tracks whether the current pan gesture already started an interactive transition.
    private var isSwipeGestureDrivingTransition = false

    /// Indicates that UIKit should wire the next transition to the pan interactor.
    private var shouldUsePanInteractorForCurrentTransition = false

    /// True while a programmatic selection setter has already prepared its transition source.
    private var isApplyingPreparedSelection = false
    
    /// Pan gesture for the swiping interaction
    //swiftlint:disable next implicitly_unwrapped_optional
    private var panGestureRecognizer: UIPanGestureRecognizer?

    @available(*, deprecated, message: "For the moment the diagonal swipe configuration is not available.")
    /// Toggle the diagonal swipe to remove the just `perfect` horizontal swipe interaction
    /// needed to perform the transition.
    open var diagonalSwipeEnabled = true

    /// Enables/Disables swipes on the tabbar controller.
    open var isSwipeEnabled = true {
        didSet { panGestureRecognizer?.isEnabled = isSwipeEnabled }
    }

    /// Allowed swipe directions. Only applied if `isSwipeEnabled` equals `true`.
    open var allowedSwipeDirection: AllowedSwipeDirection = .both

    /// Enables/Disables cycling swipes on the tabBar controller. default value is 'false'
    open var isCyclingEnabled = false
    
    /// The minimum number of touches required to match. default value is '1'
    open var minimumNumberOfTouches: Int = 1 {
        didSet {
            guard panGestureRecognizer != nil else {
                return
            }
            panGestureRecognizer?.minimumNumberOfTouches = minimumNumberOfTouches
        }
    }
    
    /// The maximum number of touches that can be down. default value is 'UINT_MAX'
    open var maximumNumberOfTouches: Int = .max {
        didSet {
            guard panGestureRecognizer != nil else {
                return
            }
            panGestureRecognizer?.maximumNumberOfTouches = maximumNumberOfTouches
        }
    }
    
    /// Override selectedIndex for Programmatic changes
    open override var selectedIndex: Int {
        get { return super.selectedIndex }
        set {
            selectIndex(newValue)
        }
    }

    /// Override selectedViewController for programmatic changes.
    open override var selectedViewController: UIViewController? {
        get { return super.selectedViewController }
        set {
            guard let viewController = newValue,
                containsViewController(viewController) else {
                    guard transitionCoordinator == nil else {
                        return
                    }
                    super.selectedViewController = newValue
                    return
            }

            selectViewController(viewController)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    private func setup() {
        currentAnimatedTransitioningType = tapAnimatedTransitioning
        // UITabBarControllerDelegate for transitions.
        delegate = self
        // Gesture setup
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerDidPan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        panGestureRecognizer = panGesture
    }

    private func selectIndex(_ index: Int, source: SelectionSource = .tap, usesPanInteractor: Bool = false) {
        guard transitionCoordinator == nil else {
            queueSelectedIndex(index, source: source)
            return
        }

        prepareTransition(from: source, usesPanInteractor: usesPanInteractor)
        isApplyingPreparedSelection = true
        defer { isApplyingPreparedSelection = false }
        super.selectedIndex = index
    }

    private func selectViewController(_ viewController: UIViewController, source: SelectionSource = .tap) {
        guard transitionCoordinator == nil else {
            queueSelection(.viewController(viewController, source))
            return
        }

        prepareTransition(from: source, usesPanInteractor: false)
        isApplyingPreparedSelection = true
        defer { isApplyingPreparedSelection = false }
        super.selectedViewController = viewController
    }

    private func containsViewController(_ viewController: UIViewController) -> Bool {
        return viewControllers?.contains { $0 === viewController } == true
    }

    private func queueSelectedIndex(_ index: Int, source: SelectionSource = .tap) {
        queueSelection(.index(index, source))
    }

    private func queueSelection(_ selection: PendingSelection) {
        pendingSelection = selection
        schedulePendingSelectionHandler()

        guard !selectionMatchesCurrentState(selection) else {
            return
        }

        [swipeAnimatedTransitioning, tapAnimatedTransitioning].forEach { $0?.forceTransitionToFinish() }
    }

    private func selectionMatchesCurrentState(_ selection: PendingSelection) -> Bool {
        switch selection {
        case .index(let index, _):
            return index == super.selectedIndex
        case .viewController(let viewController, _):
            return super.selectedViewController === viewController
        }
    }

    private func schedulePendingSelectionHandler() {
        guard !isPendingSelectionHandlerScheduled else {
            return
        }

        isPendingSelectionHandlerScheduled = true

        guard let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { [weak self] in
                self?.completePendingSelection()
            }
            return
        }

        let didScheduleCompletion = coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            DispatchQueue.main.async {
                self?.completePendingSelection()
            }
        }

        guard didScheduleCompletion else {
            DispatchQueue.main.async { [weak self] in
                self?.completePendingSelection()
            }
            return
        }
    }

    private func completePendingSelection() {
        isPendingSelectionHandlerScheduled = false
        applyPendingSelectionIfNeeded()
    }

    private func applyPendingSelectionIfNeeded() {
        guard let selection = pendingSelection else {
            return
        }

        pendingSelection = nil

        switch selection {
        case .index(let nextSelectedIndex, let source):
            guard nextSelectedIndex != super.selectedIndex else {
                return
            }
            selectIndex(nextSelectedIndex, source: source, usesPanInteractor: false)
        case .viewController(let viewController, let source):
            guard super.selectedViewController !== viewController,
                containsViewController(viewController) else {
                    return
            }
            selectViewController(viewController, source: source)
        }
    }

    private func prepareTransition(from source: SelectionSource, usesPanInteractor: Bool) {
        shouldUsePanInteractorForCurrentTransition = usesPanInteractor

        switch source {
        case .swipe:
            currentAnimatedTransitioningType = swipeAnimatedTransitioning
        case .tap:
            currentAnimatedTransitioningType = tapAnimatedTransitioning
        }
    }

    @IBAction func panGestureRecognizerDidPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended || sender.state == .cancelled {
            currentAnimatedTransitioningType = tapAnimatedTransitioning
            isSwipeGestureDrivingTransition = false
            shouldUsePanInteractorForCurrentTransition = false
        }
        
        if sender.state == .began || sender.state == .changed {
            // Do not attempt to begin an interactive transition if one is already happening
            guard transitionCoordinator == nil else {
                if !isSwipeGestureDrivingTransition,
                    let nextSelectedIndex = selectedIndex(for: sender.translation(in: view)) {
                    queueSelectedIndex(nextSelectedIndex, source: .swipe)
                }
                return
            }
            currentAnimatedTransitioningType = swipeAnimatedTransitioning
            beginInteractiveTransitionIfPossible(sender)
        }
    }
    
    /// Starts the transition by changing the selected index if the
    /// gesture allows it.
    ///
    /// - Parameter sender: gesture recognizer
    private func beginInteractiveTransitionIfPossible(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        if let nextSelectedIndex = selectedIndex(for: translation) {
            isSwipeGestureDrivingTransition = true
            selectIndex(nextSelectedIndex, source: .swipe, usesPanInteractor: true)
        } else {
            // Don't reset the gesture recognizer if we skipped starting the
            // transition because we don't have a translation yet (and thus, could
            // not determine the transition direction).
            if !translation.equalTo(CGPoint.zero) {
                // There is not a view controller to transition to, force the
                // gesture recognizer to fail.
                sender.isEnabled = false
                sender.isEnabled = true
            }
        }
        
        guard let coordinator = transitionCoordinator else {
            shouldUsePanInteractorForCurrentTransition = false
            isSwipeGestureDrivingTransition = false
            return
        }

        coordinator.animate(alongsideTransition: nil) { [unowned self] context in
            self.shouldUsePanInteractorForCurrentTransition = false
            if context.isCancelled && sender.state == .changed {
                self.beginInteractiveTransitionIfPossible(sender)
            }
        }
    }

    private func selectedIndex(for translation: CGPoint) -> Int? {
        if translation.x > 0.0 && selectedIndex > 0 {
            // Panning right, transition to the left view controller.
            return selectedIndex - 1
        } else if translation.x < 0.0 && selectedIndex + 1 < viewControllers?.count ?? 0 {
            // Panning left, transition to the right view controller.
            return selectedIndex + 1
        } else if isCyclingEnabled && translation.x > 0.0 && selectedIndex == 0 {
            // Panning right at first view controller, transition to the last view controller.
            if let count = viewControllers?.count, count >= 2 {
                return count - 1
            }
        } else if isCyclingEnabled && translation.x < 0.0 && selectedIndex + 1 == viewControllers?.count ?? 0 {
            // Panning left at last view controller, transition to the first view controller
            return 0
        }

        return nil
    }
}

extension SwipeableTabBarController {
    public enum AllowedSwipeDirection {
        case left
        case right
        case both
    }
}

extension SwipeableTabBarController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer, isSwipeEnabled else { return true }
        let translation = panGesture.translation(in: view)
        switch allowedSwipeDirection {
        case .left:
            return translation.x > 0
        case .right:
            return translation.x > 0
        case .both:
            return true
        }
    }
}

// MARK: - UITabBarControllerDelegate
extension SwipeableTabBarController: UITabBarControllerDelegate {

    open func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Get the indexes of the ViewControllers involved in the animation to determine the animation flow.
        guard let fromVCIndex = tabBarController.viewControllers?.firstIndex(of: fromVC),
            let toVCIndex = tabBarController.viewControllers?.firstIndex(of: toVC) else {
                return nil
        }
        var edge: UIRectEdge = fromVCIndex > toVCIndex ? .right : .left

        let controllersCount = viewControllers?.count ?? 0
        if isCyclingEnabled && fromVCIndex == controllersCount - 1 && toVCIndex == 0 {
            edge = .left
        } else if isCyclingEnabled && fromVCIndex == 0 && toVCIndex == controllersCount - 1 {
            edge = .right
        }

        currentAnimatedTransitioningType?.targetEdge = edge
        return currentAnimatedTransitioningType
    }

    open func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let panGesture = panGestureRecognizer else { return nil }
        if shouldUsePanInteractorForCurrentTransition && (panGesture.state == .began || panGesture.state == .changed) {
            return SwipeInteractor(gestureRecognizer: panGesture, edge: currentAnimatedTransitioningType?.targetEdge ?? .right)
        } else {
            return nil
        }
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard transitionCoordinator == nil else {
            if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
                queueSelectedIndex(index, source: .tap)
            }
            return false
        }

        if !isApplyingPreparedSelection {
            prepareTransition(from: .tap, usesPanInteractor: false)
        }
        return true
    }
}
