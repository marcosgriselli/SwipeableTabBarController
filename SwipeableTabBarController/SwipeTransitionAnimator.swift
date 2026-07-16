//
//  SwipeTransitionAnimator.swift
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
            // Clear the propertyAnimator reference AFTER the completion has fired
            // so that a re-entrant call to `forceTransitionToFinish` (e.g. from
            // the new `pendingSelectedIndex` recovery path in
            // SwipeableTabBarController) sees the correct state and doesn't try
            // to stop an animator that's already finished.
            self?.propertyAnimator = nil
        }
        propertyAnimator = animator
        return animator
    }

    func forceTransitionToFinish() {
        // Defensive state check: only stop/finish if the animator is currently
        // active. The original implementation unconditionally called
        // `stopAnimation(false)` followed by a state check for `.stopped`, but:
        //   (a) `stopAnimation(false)` on an `.inactive` animator raises an
        //       exception and was a secondary contributor to the freeze in
        //       issue #52 when `forceTransitionToFinish` was invoked re-entrantly
        //       from the `selectedIndex` setter during a queued recovery.
        //   (b) The original code had a misleading indentation that suggested
        //       the `if animator.state == .stopped` check was meant to gate
        //       `finishAnimation(at:)`, but in practice it always ran.
        // We now gate on `.active` (the only valid state to call
        // `stopAnimation` from) and clear the reference defensively.
        guard let animator = propertyAnimator else {
            return
        }
        guard animator.state == .active else {
            // Animator is already `.stopped` or `.inactive`. Nothing to stop.
            // Clear the reference if it's been left dangling.
            propertyAnimator = nil
            return
        }
        animator.stopAnimation(false)
        // After `stopAnimation(false)` the state is `.stopped`, which is the
        // only valid state from which `finishAnimation(at:)` may be called.
        animator.finishAnimation(at: .end)
        // The completion handler registered above will fire asynchronously and
        // clear `propertyAnimator`. Don't pre-empt it here — code that calls
        // `forceTransitionToFinish` expects the completion to still fire so
        // that `transitionContext.completeTransition(...)` is invoked.
    }
}
