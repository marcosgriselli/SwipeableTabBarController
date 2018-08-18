//
//  MGSwipeableTabBarController.swift
//  MGSwipeableTabBarController
//
//  Created by Marcos Griselli on 1/26/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit

/// `UITabBarController` subclass with a `selectedViewController` property observer,
/// `SwipeInteractor` that handles the swiping between tabs gesture, and a `SwipeTransitioningProtocol`
/// that determines the animation to be added. Use it or subclass it.
open class SwipeableTabBarController: UITabBarController {

    // MARK: - Private API
    fileprivate var swipeInteractor = SwipeInteractor()
    fileprivate var swipeAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeAnimation()
    fileprivate var tapAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeAnimation()
    fileprivate var currentAnimatedTransitioningType: SwipeTransitioningProtocol? = SwipeAnimation()

    private let kSelectedViewControllerKey = "selectedViewController"
    private let kSelectedIndexKey = "selectedIndex"

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    private func setup() {
        // Set the closure for finishing the transition
        swipeInteractor.onfinishTransition = { [unowned self] in
            if let controllers = self.viewControllers, let selectedController = controllers[safe: self.selectedIndex] {
                self.selectedViewController = selectedController
                self.delegate?.tabBarController?(self, didSelect: selectedController)
            }
        }

        // Make swipeAnimatedTransitioning the current one when the user begins the
        // swipe interaction.
        swipeInteractor.willBeginTransition = { [unowned self] in
            self.currentAnimatedTransitioningType = self.swipeAnimatedTransitioning
        }

        // UITabBarControllerDelegate for transitions.
        delegate = self

        // Observe selected index changes to wire the gesture recognizer to the viewController.
        addObserver(self, forKeyPath: kSelectedViewControllerKey, options: .new, context: nil)
        addObserver(self, forKeyPath: kSelectedIndexKey, options: .new, context: nil)
    }

    /// Checks if a transition is being performed.
    private var isTransitioning: Bool {
        return [swipeAnimatedTransitioning, tapAnimatedTransitioning]
            .compactMap { $0 }
            .contains { $0.transitionStarted }
    }

    // MARK: - Public API

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        // .selectedViewController changes so we setup the swipe interactor to the new selected Controller.
        if keyPath == kSelectedViewControllerKey || keyPath == kSelectedIndexKey {
            if let selectedController = selectedViewController {
                swipeInteractor.wireTo(viewController: selectedController.firstController())
            }
        }
    }

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
    open func setDiagonalSwipe(enabled: Bool) {
        swipeInteractor.isDiagonalSwipeEnabled = enabled
    }

    /// Enables/Disables swipes on the tabbar controller.
    open var isSwipeEnabled = true {
        didSet { swipeInteractor.isEnabled = isSwipeEnabled }
    }
}

// MARK: - UITabBarControllerDelegate
extension SwipeableTabBarController: UITabBarControllerDelegate {

    open func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        // Get the indexes of the ViewControllers involved in the animation to determine the animation flow.
        guard let fromVCIndex = tabBarController.viewControllers?.index(of: fromVC),
            let toVCIndex   = tabBarController.viewControllers?.index(of: toVC) else {
                return nil
        }

        currentAnimatedTransitioningType?.fromLeft = fromVCIndex > toVCIndex
        return currentAnimatedTransitioningType
    }

    open func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeInteractor.interactionInProgress ? swipeInteractor : nil
    }

    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Transitioning or interacting.
        if isTransitioning || swipeInteractor.interactionInProgress {
            return false
        }
        currentAnimatedTransitioningType = tapAnimatedTransitioning
        return true
    }
}
