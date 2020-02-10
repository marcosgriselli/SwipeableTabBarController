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
    var animationType: SwipeTransitionAnimationType

    /// Init with injectable parameters
    ///
    /// - Parameters:
    ///   - animationDuration: time the transitioning animation takes to complete
    ///   - animationType: animation type to perform while transitioning
    init(animationDuration: TimeInterval = 0.33,
         targetEdge: UIRectEdge = .right,
         animationType: SwipeTransitionAnimationType = .sideBySide) {
        self.animationDuration = animationDuration
        self.targetEdge = targetEdge
        self.animationType = animationType
        super.init()
    }

    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated == true ? animationDuration : 0
        
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else {
                return
        }
        
        let duration = transitionDuration(using: transitionContext)
        let direction = SwipeTransitionAnimationDirection(rectEdge: targetEdge)
        let animationContext = SwipeTransitionAnimationContext(containerView: containerView, fromView: fromView, toView: toView)
        
        animationType.prepareForAnimate(withContext: animationContext)
        
        animationType.animate(duration: duration,
                              direction: direction,
                              context: animationContext) { _ in
                                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
