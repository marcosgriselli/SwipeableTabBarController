//
//  MGSwipeAnimation.swift
//  MGSwipeableTabBarController
//
//  Created by Marcos Griselli on 1/31/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit


// TODO (marcosgriselli): Support different types of swipe animations (overlap, side by side, push-style?)
class SwipeAnimation: NSObject {
    
    fileprivate var animationDuration: TimeInterval!
    fileprivate var animationStarted = false
    
    // TODO (marcosgriselli): add support for snapshot views.
    
    var fromLeft = false
    
    init(animationDuration: TimeInterval? = 0.33) {
        super.init()
        self.animationDuration = animationDuration
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
        let screenWidth = UIScreen.main.bounds.size.width
        fromView?.endEditing(true)
        
        containerView.addSubview(fromView!)
        fromView?.frame = CGRect(x: 0,
                                 y: 0,
                                 width: fromView!.frame.width,
                                 height: fromView!.frame.height)
        
        containerView.addSubview(toView!)
        toView?.frame = CGRect(x: fromLeft ? -screenWidth : screenWidth,
                               y: 0,
                               width: toView!.frame.width,
                               height: toView!.frame.height)
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseOut],
                       animations: {
                        toView?.frame.origin.x = 0
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
