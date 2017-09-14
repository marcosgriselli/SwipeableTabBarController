//
//  MGSwipeAnimation.swift
//  MGSwipeableTabBarController
//
//  Created by Marcos Griselli on 1/31/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit

/// Swipe animation conforming to `UIViewControllerAnimatedTransitioning`
/// Can be replaced by any other class confirming to `UIViewControllerTransitioning`
/// on your `SwipeableTabBarController` subclass.
class SwipeAnimation: NSObject, SwipeTransitioningProtocol {

    /// Duration of the transition animation.
    fileprivate var animationDuration: TimeInterval!

    /// Is currently performing an animation
    fileprivate var animationStarted = false
    
    // TODO: - (marcosgriselli) add support for snapshot views.
    /// Side which de animation will be performed from.
    var fromLeft = false

    /// Swipe animation type to perform animation
    var animationType: SwipeAnimationTypeProtocol = SwipeAnimationType.sideBySide

    /// Init with injectable parameters
    ///
    /// - Parameters:
    ///   - animationDuration: time the transitioning animation takes to complete
    ///   - animationType: animation type to perform while transitioning
    init(animationDuration: TimeInterval = 0.33,
         animationType: SwipeAnimationTypeProtocol = SwipeAnimationType.sideBySide) {
        super.init()
        self.animationDuration = animationDuration
        self.animationType = animationType
    }

    // MARK: - UIViewControllerAnimatedTransitioning
    
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
                       completion: {[unowned self] _ in
                        self.finishedTransition(fromView: fromView,
                                                toView: toView,
                                                in: transitionContext)
        })
    }

    /// Finished transition
    ///
    /// - Parameters:
    ///   - fromView: view we are transitioning from
    ///   - toView: view we are transitioning to
    ///   - context: transitioning context
    private func finishedTransition(fromView: UIView?,
                                    toView: UIView?,
                                    in context: UIViewControllerContextTransitioning) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.animationStarted = false
            if context.transitionWasCancelled {
                toView?.removeFromSuperview()
            } else {
                fromView?.removeFromSuperview()
            }
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
}
