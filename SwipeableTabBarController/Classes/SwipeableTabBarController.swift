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
    private(set) public var swipeAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeTransitionAnimator()
    
    /// Animated transition to be performed when tapping on a tabbar item
    private(set) public var tapAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeTransitionAnimator()
    
    /// Animated transition being used currently
    private var currentAnimatedTransitioningType: SwipeTransitioningProtocol?
    
    /// Pan gesture for the swiping interaction
    //swiftlint:disable next implicitly_unwrapped_optional
    private var panGestureRecognizer: UIPanGestureRecognizer!

    @available(*, deprecated, message: "For the moment the diagonal swipe configuration is not available.")
    /// Toggle the diagonal swipe to remove the just `perfect` horizontal swipe interaction
    /// needed to perform the transition.
    open var diagonalSwipeEnabled = true

    /// Enables/Disables swipes on the tabbar controller.
    open var isSwipeEnabled = true {
        didSet { panGestureRecognizer.isEnabled = isSwipeEnabled }
    }

    /// Enables/Disables cycling swipes on the tabBar controller. default value is 'false'
    open var isCyclingEnabled = false

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    private func setup() {
        // UITabBarControllerDelegate for transitions.
        delegate = self
        currentAnimatedTransitioningType = tapAnimatedTransitioning
        // Gesture setup
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerDidPan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    @IBAction func panGestureRecognizerDidPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            currentAnimatedTransitioningType = tapAnimatedTransitioning
        }
        // Do not attempt to begin an interactive transition if one is already
        // ongoing
        if transitionCoordinator != nil {
            return
        }
        
        if sender.state == .began {
            currentAnimatedTransitioningType = swipeAnimatedTransitioning
        }

        if sender.state == .began || sender.state == .changed {
            beginInteractiveTransitionIfPossible(sender)
        }
    }
    
    /// Starts the transition by changing the selected index if the
    /// gesture allows it.
    ///
    /// - Parameter sender: gesture recognizer
    private func beginInteractiveTransitionIfPossible(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        if translation.x > 0.0 && selectedIndex > 0 {
            // Panning right, transition to the left view controller.
            selectedIndex -= 1
        } else if translation.x < 0.0 && selectedIndex + 1 < viewControllers?.count ?? 0 {
            // Panning left, transition to the right view controller.
            selectedIndex += 1
        } else if isCyclingEnabled && translation.x > 0.0 && selectedIndex == 0 {
            // Panning right at first view controller, transition to the last view controller.
            if let count = viewControllers?.count, count >= 2 {
                selectedIndex = count - 1
            }
        } else if isCyclingEnabled && translation.x < 0.0 && selectedIndex + 1 == viewControllers?.count ?? 0 {
            // Panning left at last view controller, transition to the first view controller
            selectedIndex = 0
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
        
        transitionCoordinator?.animate(alongsideTransition: nil) { [unowned self] context in
            if context.isCancelled && sender.state == .changed {
                self.beginInteractiveTransitionIfPossible(sender)
            }
        }
    }
}

// MARK: - UITabBarControllerDelegate
extension SwipeableTabBarController: UITabBarControllerDelegate {

    open func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Get the indexes of the ViewControllers involved in the animation to determine the animation flow.
        guard let fromVCIndex = tabBarController.viewControllers?.index(of: fromVC),
            let toVCIndex = tabBarController.viewControllers?.index(of: toVC) else {
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
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            return SwipeInteractor(gestureRecognizer: panGestureRecognizer, edge: currentAnimatedTransitioningType?.targetEdge ?? .right)
        } else {
            return nil
        }
    }
}
