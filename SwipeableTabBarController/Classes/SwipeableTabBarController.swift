//
//  MGSwipeableTabBarController.swift
//  MGSwipeableTabBarController
//
//  Created by Marcos Griselli on 1/26/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit

open class SwipeableTabBarController: UITabBarController {
    
    // TODO (marcosgriselli): Create protocols for this so users
    // can swap for their own interactors/animations
    fileprivate var swipeInteractor: SwipeInteractor!
    fileprivate var swipeAnimatedTransitioning: SwipeAnimation!
    
    private let kSelectedViewControllerKey = "selectedViewController"

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        // Set the interactor that will handle the swipes
        swipeInteractor = SwipeInteractor()
        swipeInteractor.onfinishTransition = {
            if let controllers = self.viewControllers {
                self.selectedViewController = controllers[self.selectedIndex]
            }
        }
        // Set the animation to excecute with swipe percentage
        swipeAnimatedTransitioning = SwipeAnimation()

        // UITabBarControllerDelegate for transitions.
        delegate = self

        // Observe selected index changes to wire the gesture recognizer to the viewController.
        addObserver(self, forKeyPath: kSelectedViewControllerKey, options: .new, context: nil)
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == kSelectedViewControllerKey {
            if let selectedController = selectedViewController {
                swipeInteractor.wireTo(viewController: selectedController)
            }
        }
    }
}

extension SwipeableTabBarController: UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
        // Get the indexes of the ViewControllers involved in the animation to determine the animation flow. 
        guard let fromVCIndex = tabBarController.viewControllers?.index(of: fromVC),
              let toVCIndex   = tabBarController.viewControllers?.index(of: toVC) else {
                return nil
        }
        
        swipeAnimatedTransitioning.fromLeft = fromVCIndex > toVCIndex
        return swipeAnimatedTransitioning
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeInteractor.interactionInProgress ? swipeInteractor : nil
    }
}
