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

    /// Duration of the transition animation.
    fileprivate var animationDuration: TimeInterval

    // MARK: - SwipeTransitioningProtocol
    var targetEdge: UIRectEdge
    var animationType: SwipeAnimationTypeProtocol = SwipeAnimationType.sideBySide
    var transitionStarted = false

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
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        let fromFrame = transitionContext.initialFrame(for: fromViewController)
        let toFrame = transitionContext.finalFrame(for: toViewController)
        
        // Based on the configured targetEdge, derive a normalized vector that will
        // be used to offset the frame of the view controllers.
        var offset: CGVector
        switch targetEdge {
        case .left:
            offset = CGVector(dx: -1.0, dy: 0.0)
        case .right:
            offset = CGVector(dx: 1.0, dy: 0.0)
        default:
            fatalError("targetEdge must be one of UIRectEdge.left, or UIRectEdge.right.")
        }
        
        // The toView starts off-screen and slides in as the fromView slides out.
        fromView.frame = fromFrame
        toView.frame = toFrame.offsetBy(dx: toFrame.size.width * offset.dx * -1,
                                        dy: toFrame.size.height * offset.dy * -1)
        
        // We are responsible for adding the incoming view to the containerView.
        containerView.addSubview(toView)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            fromView.frame = fromFrame.offsetBy(dx: fromFrame.size.width * offset.dx,
                                                dy: fromFrame.size.height * offset.dy)
            toView.frame = toFrame
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
