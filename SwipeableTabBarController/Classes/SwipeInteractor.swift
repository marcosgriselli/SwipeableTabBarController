//
//  MGSwipeInteractor.swift
//  MGSwipeableTabBarController
//
//  Created by Marcos Griselli on 1/26/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit

class SwipeInteractor: UIPercentDrivenInteractiveTransition {
    
    private var viewController: UIViewController!
    private var rightToLeftSwipe = false
    private var shouldCompleteTransition = false
    
    private let kSwipeVelocityForComplete: CGFloat = 200.0
    private let kSwipeGestureKey = "kSwipeableTabBarControllerGestureKey"
    
    var interactionInProgress = false

    
    /// Sets the viewController to be the one in charge of handling the swipe transition.
    ///
    /// - Parameter viewController: `UIViewController` in charge of the the transition.
    func wireTo(viewController: UIViewController) {
        self.viewController = viewController
        prepareGestureRecognizer(inView: viewController.view)
    }
    
    
    /// Adds the `UIPanGestureRecognizer` to the controller's view to handle swiping.
    ///
    /// - Parameter view: `UITabBarController` tab controller's view (`UINavigationControllers` not included).
    func prepareGestureRecognizer(inView view: UIView) {
        var panRecognizer = objc_getAssociatedObject(view, kSwipeGestureKey) as? UIPanGestureRecognizer
        
        if let swipe = panRecognizer {
            view.removeGestureRecognizer(swipe)
        }
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeInteractor.handlePan(_:)))
        view.addGestureRecognizer(panRecognizer!)
        objc_setAssociatedObject(view, kSwipeGestureKey, panRecognizer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    
    /// Handles the swiping with progress
    ///
    /// - Parameter recognizer: `UIPanGestureRecognizer` in the current tab controller's view.
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: recognizer.view?.superview)
        let velocity = recognizer.velocity(in: recognizer.view)
    
        switch recognizer.state {
        case .began:
            rightToLeftSwipe = velocity.x < 0
            if rightToLeftSwipe {
                if viewController.tabBarController!.selectedIndex < viewController.tabBarController!.viewControllers!.count - 1 {
                    interactionInProgress = true
                    viewController.tabBarController?.selectedIndex += 1
                }
            } else {
                if viewController.tabBarController!.selectedIndex > 0 {
                    interactionInProgress = true
                    viewController.tabBarController?.selectedIndex -= 1
                }
            }
        case .changed:
            if interactionInProgress {
                var fraction = fabs(translation.x/UIScreen.main.bounds.size.width)
                fraction = min(max(fraction, 0.0), 1.0)
                shouldCompleteTransition = (fraction > 0.5);
                self.update(fraction)
            }
            
        case .ended, .cancelled:
            if interactionInProgress {
                interactionInProgress = false
                if !shouldCompleteTransition {
                    if (rightToLeftSwipe && velocity.x < -kSwipeVelocityForComplete) {
                        shouldCompleteTransition = true
                    } else if (!rightToLeftSwipe && velocity.x > kSwipeVelocityForComplete) {
                        shouldCompleteTransition = true
                    }
                }
                
                if !shouldCompleteTransition || recognizer.state == .cancelled {
                    cancel()
                } else {
                    finish()
                }
            }
            
        default : break
        }
    }
}
