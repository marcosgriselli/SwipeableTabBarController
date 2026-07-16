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

    /// Pan gesture for the swiping interaction
    //swiftlint:disable next implicitly_unwrapped_optional
    private var panGestureRecognizer: UIPanGestureRecognizer?

    // MARK: - Transition state tracking (fix for issue #52 — freeze on very fast swipes)

    /// Explicit transition-in-flight flag.
    ///
    /// `transitionCoordinator` briefly returns `nil` between the moment a gesture
    /// ends and the animation's completion handler fires. Relying solely on it
    /// allowed a fast second swipe to start a new transition that raced with the
    /// pending cleanup of the previous one, leaving the view hierarchy in an
    /// inconsistent state where `UIView.animate` completions never fired.
    ///
    /// This flag is set to `true` as soon as an interactive transition begins
    /// and cleared only when the transition's completion handler (registered
    /// via `transitionCoordinator?.notifyWhenInteractionChanges { ... }`) runs.
    private var isTransitionInProgress: Bool = false

    /// Pending tab selection triggered while a transition was already in flight.
    ///
    /// When a very fast swipe fires a second `.began` event while
    /// `isTransitionInProgress == true`, instead of dropping the gesture or
    /// racing with the running animation, we record the requested target index
    /// here. Once the in-flight transition completes, we apply the pending
    /// selection. This matches the maintainer's own diagnosis in the issue
    /// thread: *"it is trying to start a transition before the previous one
    /// finished."*
    private var pendingSelectedIndex: Int?

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
            // If a transition is already in flight, queue this request instead of
            // interrupting mid-flight. This avoids `forceTransitionToFinish()` being
            // invoked re-entrantly, which was a secondary contributor to the freeze
            // (the property animator was being stopped while its completion handler
            // was still pending, leaving the transition context in a half-finished
            // state and blocking subsequent `UIView.animate` calls from ever firing
            // their completions).
            if isTransitionInProgress || transitionCoordinator != nil {
                if pendingSelectedIndex != newValue {
                    pendingSelectedIndex = newValue
                }
                // Force any in-flight interactive animation to finish immediately
                // so the queued index can be applied on the completion callback.
                [swipeAnimatedTransitioning, tapAnimatedTransitioning].forEach { $0?.forceTransitionToFinish() }
                return
            }
            super.selectedIndex = newValue
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

    @IBAction func panGestureRecognizerDidPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended || sender.state == .cancelled {
            currentAnimatedTransitioningType = tapAnimatedTransitioning
        }

        if sender.state == .began || sender.state == .changed {
            // Do not attempt to begin an interactive transition if one is already
            // happening. The original implementation relied on
            // `transitionCoordinator == nil` alone, which is briefly true between
            // the end of one gesture and the completion of the prior animation.
            // The explicit `isTransitionInProgress` flag closes that window.
            guard !isTransitionInProgress, transitionCoordinator == nil else {
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

        // Determine the target index for this gesture (without applying it yet).
        // We compute the target first so we can mark `isTransitionInProgress`
        // atomically with actually starting the transition — closing the race
        // window between "selectedIndex -= 1" and the transitionCoordinator
        // becoming non-nil.
        var targetIndex: Int? = nil
        if translation.x > 0.0 && selectedIndex > 0 {
            // Panning right, transition to the left view controller.
            targetIndex = selectedIndex - 1
        } else if translation.x < 0.0 && selectedIndex + 1 < viewControllers?.count ?? 0 {
            // Panning left, transition to the right view controller.
            targetIndex = selectedIndex + 1
        } else if isCyclingEnabled && translation.x > 0.0 && selectedIndex == 0 {
            // Panning right at first view controller, transition to the last view controller.
            if let count = viewControllers?.count, count >= 2 {
                targetIndex = count - 1
            }
        } else if isCyclingEnabled && translation.x < 0.0 && selectedIndex + 1 == viewControllers?.count ?? 0 {
            // Panning left at last view controller, transition to the first view controller
            targetIndex = 0
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
            return
        }

        guard let resolvedTarget = targetIndex else { return }

        // Atomic transition entry: mark in-progress BEFORE setting selectedIndex
        // so a re-entrant gesture event observed during the property setter's
        // side effects sees the flag and is queued instead of racing.
        isTransitionInProgress = true
        super.selectedIndex = resolvedTarget

        // Register a completion callback that reliably clears the flag — even
        // if the animation is cancelled, interrupted, or `forceTransitionToFinish`
        // is invoked. `transitionCoordinator` is non-nil at this point because
        // we just triggered the transition by setting selectedIndex above.
        if let coordinator = transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { [weak self] context in
                guard let self = self else { return }
                self.isTransitionInProgress = false
                // If a selection was queued while this transition was in flight,
                // apply it now. Use `super.selectedIndex` to bypass our own
                // setter's queueing logic (the in-flight flag is already clear).
                if let pending = self.pendingSelectedIndex, pending != self.selectedIndex {
                    self.pendingSelectedIndex = nil
                    // Re-enter through the public setter so the new transition
                    // also gets tracked properly.
                    self.selectedIndex = pending
                } else {
                    self.pendingSelectedIndex = nil
                }
            }
        } else {
            // Defensive: if transitionCoordinator is nil right after we set
            // selectedIndex (e.g. tabBarController(_:shouldSelect:) returned false,
            // or the system coalesced the change), clear the flag immediately.
            isTransitionInProgress = false
        }

        // Retain the original alongsideTransition block for the cancel-retry
        // behaviour on .changed state, but guard it with the in-progress flag so
        // we never re-enter `beginInteractiveTransitionIfPossible` recursively
        // while the flag is still set.
        transitionCoordinator?.animate(alongsideTransition: nil) { [unowned self] context in
            if context.isCancelled && sender.state == .changed && !self.isTransitionInProgress {
                self.beginInteractiveTransitionIfPossible(sender)
            }
        }
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
        if panGesture.state == .began || panGesture.state == .changed {
            return SwipeInteractor(gestureRecognizer: panGesture, edge: currentAnimatedTransitioningType?.targetEdge ?? .right)
        } else {
            return nil
        }
    }

    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Allow selection if no transition is in flight OR if this very call is
        // the one that started the transition (we just set super.selectedIndex
        // inside beginInteractiveTransitionIfPossible and isTransitionInProgress
        // is already true).
        // The original `transitionCoordinator == nil` check caused the shouldSelect
        // delegate call to return false for queued selections applied from the
        // completion handler, blocking the recovery path. We now also accept
        // selection while `isTransitionInProgress` is true, because the only
        // writer of that flag is the transition starter itself.
        return transitionCoordinator == nil || isTransitionInProgress
    }
}
