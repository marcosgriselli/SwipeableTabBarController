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
    fileprivate var animationDuration: TimeInterval

    // TODO: - (marcosgriselli) add support for snapshot views.
    // MARK: - SwipeTransitioningProtocol
    var fromLeft = false
    var animationType: SwipeAnimationTypeProtocol = SwipeAnimationType.sideBySide
    var transitionStarted = false

    /// Init with injectable parameters
    ///
    /// - Parameters:
    ///   - animationDuration: time the transitioning animation takes to complete
    ///   - animationType: animation type to perform while transitioning
    init(animationDuration: TimeInterval = 0.33,
         animationType: SwipeAnimationTypeProtocol = SwipeAnimationType.sideBySide) {
        self.animationDuration = animationDuration
        self.animationType = animationType
        super.init()
    }

    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return (transitionContext?.isAnimated == true) ? animationDuration : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Pre check if there's a previous transition runing and cancel the current one.
        if transitionStarted {
            return transitionContext.completeTransition(false)
        }

        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
            let toView = transitionContext.view(forKey:
                UITransitionContextViewKey.to)
            else {
                return transitionContext.completeTransition(false)
        }
        
        transitionStarted = true
        
        let duration = transitionDuration(using: transitionContext)
        fromView.endEditing(true)

        let containerView = transitionContext.containerView
        animationType.addTo(containerView: containerView, fromView: fromView, toView: toView)
        animationType.prepare(fromView: fromView, toView: toView, direction: fromLeft)
    
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseOut],
                       animations: {
                        self.animationType.animation(fromView: fromView, toView: toView, direction: self.fromLeft)
        },
                       completion: { [weak self] _ in
                        self?.finishedTransition(fromView: fromView,
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
        DispatchQueue.main.async {
            self.transitionStarted = false
            if context.transitionWasCancelled {
                self.animationType.animation(fromView: toView,
                                             toView: fromView,
                                             direction: self.fromLeft)
                toView?.removeFromSuperview()
            } else {
                self.animationType.animation(fromView: fromView,
                                             toView: toView,
                                             direction: self.fromLeft)
                fromView?.removeFromSuperview()
            }
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
}
