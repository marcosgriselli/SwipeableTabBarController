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

    // MARK: - Private API
    private var swipeAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeTransitionAnimator()
    private var tapAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeTransitionAnimator()
    private var currentAnimatedTransitioningType: SwipeTransitioningProtocol? = SwipeTransitionAnimator()
    
    private var panGestureRecognizer: UIPanGestureRecognizer!

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
        // Gesture setup
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerDidPan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    // MARK: - Public API
    
    /// Modify the swipe animation, it can be one of the default `SwipeAnimationType` or your own type
    /// conforming to `SwipeAnimationTypeProtocol`.
    ///
    /// - Parameter type: object conforming to `SwipeAnimationTypeProtocol`.
    open func setSwipeAnimation(type: SwipeAnimationTypeProtocol) {
        swipeAnimatedTransitioning?.animationType = type
    }

    /// Modify the swipe animation, it can be one of the default `SwipeAnimationType` or your own type
    /// conforming to `SwipeAnimationTypeProtocol`.
    ///
    /// - Parameter type: object conforming to `SwipeAnimationTypeProtocol`.
    open func setTapAnimation(type: SwipeAnimationTypeProtocol) {
        tapAnimatedTransitioning?.animationType = type
    }

    /// Modify the transitioning animation for swipes.
    ///
    /// - Parameter transition: UIViewControllerAnimatedTransitioning conforming to
    /// `SwipeTransitioningProtocol`.
    open func setSwipeTransitioning(transition: SwipeTransitioningProtocol?) {
        swipeAnimatedTransitioning = transition
    }
    
    /// Modify the transitioning animation for taps.
    ///
    /// - Parameter transition: UIViewControllerAnimatedTransitioning conforming to
    /// `SwipeTransitioningProtocol`.
    open func setTapTransitioning(transition: SwipeTransitioningProtocol?) {
        tapAnimatedTransitioning = transition
    }

    /// Toggle the diagonal swipe to remove the just `perfect` horizontal swipe interaction
    /// needed to perform the transition.
    ///
    /// - Parameter enabled: Bool value to the corresponding diagnoal swipe support.
    @available(*, deprecated, message: "Currently diagonal swipe has been disabled.")
    open func setDiagonalSwipe(enabled: Bool) {
//        swipeInteractor.isDiagonalSwipeEnabled = enabled
    }

    /// Enables/Disables swipes on the tabbar controller.
    open var isSwipeEnabled = true {
        didSet { panGestureRecognizer.isEnabled = isSwipeEnabled }
    }

    @IBAction func panGestureRecognizerDidPan(_ sender: UIPanGestureRecognizer) {
        // Do not attempt to begin an interactive transition if one is already
        // ongoing
        if transitionCoordinator != nil {
            return
        }
        
        // TODO: - Support
//        if sender.state == .began {
//            currentAnimatedTransitioningType = swipeAnimatedTransitioning
//        }

        if sender.state == .began || sender.state == .changed {
            beginInteractiveTransitionIfPossible(sender)
        }

        // TODO: - Support
//        if sender.state == .ended {
//            currentAnimatedTransitioningType = tapAnimatedTransitioning
//        }
    }
    
    private func beginInteractiveTransitionIfPossible(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        if translation.x > 0.0 && selectedIndex > 0 {
            // Panning right, transition to the left view controller.
            selectedIndex -= 1
        } else if translation.x < 0.0 && selectedIndex + 1 < viewControllers?.count ?? 0 {
            // Panning left, transition to the right view controller.
            selectedIndex += 1
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

        let edge: UIRectEdge = fromVCIndex > toVCIndex ? .right : .left
        currentAnimatedTransitioningType?.targetEdge = edge
        return currentAnimatedTransitioningType
    }

    open func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            return SwipeInteractor(gestureRecognizer: panGestureRecognizer)
        } else {
            return nil
        }
    }
}
