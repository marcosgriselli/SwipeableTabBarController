//
//  MGSwipeAnimation.swift
//  MGSwipeableTabBarController
//
//  Created by Marcos Griselli on 1/31/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit

class SwipeAnimation: NSObject {
    
    fileprivate var animationDuration: TimeInterval!
    fileprivate var animationStarted = false
    // TODO (marcosgriselli): add support for snapshot views.
    
    var fromLeft = false
    var animationType: SwipeAnimationType!
    
    init(animationDuration: TimeInterval? = 0.33, animationType: SwipeAnimationType? = .sideBySide) {
        super.init()
        self.animationDuration = animationDuration
        self.animationType = animationType
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension SwipeAnimation: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return (transitionContext?.isAnimated == true) ? animationDuration : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey:
                UITransitionContextViewControllerKey.to)
            else {
                return transitionContext.completeTransition(false)
        }
        
        animationStarted = true
        
        let duration = transitionDuration(using: transitionContext)
        let toView = toViewController.view
        let fromView = fromViewController.view
        fromView?.endEditing(true)
        
        animationType.addTo(containerView: containerView, fromView: fromView!, toView: toView!)
        animationType.prepare(fromView: fromView, toView: toView, direction: fromLeft)
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseOut],
                       animations: {
                        self.animationType.animation(fromView: fromView, toView: toView, direction: self.fromLeft)
        },
                       completion: {[unowned self] completed in
                        self.animationStarted = false
                        if transitionContext.transitionWasCancelled {
                            toView?.removeFromSuperview()
                        } else {
                            fromView?.removeFromSuperview()
                        }
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
