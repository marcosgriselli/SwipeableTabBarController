//
//  SwipeAnimation.swift
//  SwipeableTabBarController
//
//  Created by Marcos Griselli on 1/31/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit

/// Swipe animation conforming to `UIViewControllerAnimatedTransitioning`
/// Can be replaced by any other class confirming to `UIViewControllerTransitioning`
/// on your `SwipeableTabBarController` subclass.
@objc(SwipeTransitionAnimator)
class SwipeTransitionAnimator: NSObject, SwipeTransitioningProtocol {

    // MARK: - SwipeTransitioningProtocol
    var animationDuration: TimeInterval
    var targetEdge: UIRectEdge
    var animationType: SwipeAnimationTypeProtocol = SwipeAnimationType.sideBySide
    
    private var propertyAnimator: UIViewAnimating?

    /// Init with injectable parameters
    ///
    /// - Parameters:
    ///   - animationDuration: time the transitioning animation takes to complete
    ///   - animationType: animation type to perform while transitioning
    init(animationDuration: TimeInterval = 0.33,
         targetEdge: UIRectEdge = .right,
         animationType: SwipeAnimationTypeProtocol = SwipeAnimationType.sideBySide) {
        self.animationDuration = animationDuration
        self.targetEdge = targetEdge
        self.animationType = animationType
        super.init()
    }

    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return (transitionContext?.isAnimated == true) ? animationDuration : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let containerView = transitionContext.containerView
        //swiftlint:disable force_unwrapping
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        //swiftlint:enable force_unwrapping
        let fromRight = targetEdge == .right
        
        animationType.addTo(containerView: containerView, fromView: fromView, toView: toView)
        animationType.prepare(fromView: fromView, toView: toView, direction: fromRight)
        
        let duration = transitionDuration(using: transitionContext)
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
            self.animationType.animation(fromView: fromView, toView: toView, direction: fromRight)
        })
        animator.addCompletion { [weak self] _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self?.propertyAnimator = nil
        }
        propertyAnimator = animator
        return animator
    }
    
    func forceTransitionToFinish() {
        guard let animator = propertyAnimator else {
            return
        }
        animator.stopAnimation(false)
            if animator.state == .stopped {
                animator.finishAnimation(at: .end)
            }
    }
}
