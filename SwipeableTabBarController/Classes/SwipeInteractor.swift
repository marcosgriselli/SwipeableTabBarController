//
//  SwipeInteractor.swift
//  SwipeableTabBarController
//
//  Created by Marcos Griselli on 1/26/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit

/// Responsible of driving the interactive transtion.
@objc(SwipeInteractor)
class SwipeInteractor: UIPercentDrivenInteractiveTransition {
    
    // MARK: - Private
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private var gestureRecognizer: UIPanGestureRecognizer
    private var edge: UIRectEdge
    private var initialLocationInContainerView: CGPoint = CGPoint()
    private var initialTranslationInContainerView: CGPoint = CGPoint()
    
    private let xVelocityForComplete: CGFloat = 200.0
    private let xVelocityForCancel: CGFloat = 30.0
    
    init(gestureRecognizer: UIPanGestureRecognizer, edge: UIRectEdge) {
        self.gestureRecognizer = gestureRecognizer
        self.edge = edge
        super.init()
        
        // Add self as an observer of the gesture recognizer so that this
        // object receives updates as the user moves their finger.
        gestureRecognizer.addTarget(self, action: #selector(gestureRecognizeDidUpdate(_:)))
    }

    deinit {
        gestureRecognizer.removeTarget(self, action: #selector(gestureRecognizeDidUpdate(_:)))
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        // Save the transitionContext, initial location, and the translation within
        // the containing view.
        self.transitionContext = transitionContext
        initialLocationInContainerView = gestureRecognizer.location(in: transitionContext.containerView)
        initialTranslationInContainerView = gestureRecognizer.translation(in: transitionContext.containerView)
        
        super.startInteractiveTransition(transitionContext)
    }

    /// Returns the offset of the pan gesture recognizer from its initial location
    /// as a percentage of the transition container view's width.
    ///
    /// - Parameter gesture: swiping gesture
    /// - Returns: percent completed for the interactive transition
    private func percentForGesture(_ gesture: UIPanGestureRecognizer) -> CGFloat {
        let transitionContainerView = transitionContext?.containerView
        
        let translationInContainerView = gesture.translation(in: transitionContainerView)
        
        // If the direction of the current touch along the horizontal axis does not
        // match the initial direction, then the current touch position along
        // the horizontal axis has crossed over the initial position.
        if translationInContainerView.x > 0.0 && initialTranslationInContainerView.x < 0.0 ||
            translationInContainerView.x < 0.0 && initialTranslationInContainerView.x > 0.0 {
            return -1.0
        }
        
        // Figure out what percentage we've traveled.
        return abs(translationInContainerView.x) / (transitionContainerView?.bounds ?? CGRect()).width
    }
    
    @IBAction func gestureRecognizeDidUpdate(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            // The Began state is handled by AAPLSlideTransitionDelegate.  In
            // response to the gesture recognizer transitioning to this state,
            // it will trigger the transition.
            break
        case .changed:
            // -percentForGesture returns -1.f if the current position of the
            // touch along the horizontal axis has crossed over the initial
            // position.
            if percentForGesture(gestureRecognizer) < 0.0 {
                cancel()
                // Need to remove our action from the gesture recognizer to
                // ensure it will not be called again before deallocation.
                gestureRecognizer.removeTarget(self, action: #selector(gestureRecognizeDidUpdate(_:)))
            } else {
                update(percentForGesture(gestureRecognizer))
            }
        case .ended:
            let transitionContainerView = transitionContext?.containerView
            let velocityInContainerView = gestureRecognizer.velocity(in: transitionContainerView)
            let shouldComplete: Bool
            switch edge {
            /// TODO (marcosgriselli): - Standarize and simplify 
            case .left:
                shouldComplete = (percentForGesture(gestureRecognizer) >= 0.4 && velocityInContainerView.x < xVelocityForCancel) || velocityInContainerView.x < -xVelocityForComplete
            case .right:
                shouldComplete = (percentForGesture(gestureRecognizer) >= 0.4 && velocityInContainerView.x > -xVelocityForCancel) || velocityInContainerView.x > xVelocityForComplete
            default:
                fatalError("\(edge) is unsupported.")
            }

            if shouldComplete {
                finish()
            } else {
                cancel()
            }
        default:
            cancel()
        }
    }
}
