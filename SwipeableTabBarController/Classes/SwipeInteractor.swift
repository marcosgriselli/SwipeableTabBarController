//
//  MGSwipeInteractor.swift
//  MGSwipeableTabBarController
//
//  Created by Marcos Griselli on 1/26/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit

/// Responsible of adding the `UIPanGestureRecognizer` to the current 
/// tab selected on the `UITabBarController` subclass.
class SwipeInteractor: UIPercentDrivenInteractiveTransition {
    
    // MARK: - Private
    private var viewController: UIViewController!
    private var rightToLeftSwipe = false
    private var shouldCompleteTransition = false
    private var canceled = false
    
    // MARK: - Fileprivate
    fileprivate var panRecognizer: UIPanGestureRecognizer?
    fileprivate struct InteractionConstants {
        static let yTranslationForSuspend: CGFloat = 5.0
        static let yVelocityForSuspend: CGFloat = 100.0
        static let xVelocityForComplete: CGFloat = 200.0
        static let xTranslationForRecognition: CGFloat = 5.0
    }
    
    fileprivate struct AssociatedKey {
        static var swipeGestureKey = "kSwipeableTabBarControllerGestureKey"
    }
    
    // MARK: - Public
    var isDiagonalSwipeEnabled = false
    var interactionInProgress = false
    
    typealias Closure = (() -> ())
    var onfinishTransition: Closure?
    var willBeginTransition: Closure?
    
    /// Sets the viewController to be the one in charge of handling the swipe transition.
    ///
    /// - Parameter viewController: `UIViewController` in charge of the the transition.
    public func wireTo(viewController: UIViewController) {
        if self.viewController === viewController { return }
        self.viewController = viewController
        prepareGestureRecognizer(inView: viewController.view)
    }
    
    
    /// Adds the `UIPanGestureRecognizer` to the controller's view to handle swiping.
    ///
    /// - Parameter view: `UITabBarController` tab controller's view (`UINavigationControllers` not included).
    public func prepareGestureRecognizer(inView view: UIView) {
        panRecognizer = objc_getAssociatedObject(view, &AssociatedKey.swipeGestureKey) as? UIPanGestureRecognizer
        
        if let swipe = panRecognizer {
            view.removeGestureRecognizer(swipe)
        }
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeInteractor.handlePan(_:)))
        panRecognizer?.delegate = self
        panRecognizer?.isEnabled = isEnabled
        view.addGestureRecognizer(panRecognizer!)
        objc_setAssociatedObject(view, &AssociatedKey.swipeGestureKey, panRecognizer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    
    /// Handles the swiping with progress
    ///
    /// - Parameter recognizer: `UIPanGestureRecognizer` in the current tab controller's view.
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: recognizer.view?.superview)
        let velocity = recognizer.velocity(in: recognizer.view)
    
        switch recognizer.state {
        case .began:

            if shouldSuspendInteraction(yTranslation: translation.y, yVelocity: velocity.y) {
                interactionInProgress = false
                return
            }
            
            rightToLeftSwipe = velocity.x < 0
            if rightToLeftSwipe {
                if viewController.tabBarController!.selectedIndex < viewController.tabBarController!.viewControllers!.count - 1 {
                    willBeginTransition?()
                    interactionInProgress = true
                    viewController.tabBarController?.selectedIndex += 1
                }
            } else {
                if viewController.tabBarController!.selectedIndex > 0 {
                    willBeginTransition?()
                    interactionInProgress = true
                    viewController.tabBarController?.selectedIndex -= 1
                }
            }
        case .changed:
            if interactionInProgress {
                let translationValue = translation.x/UIScreen.main.bounds.size.width
                
                // TODO (marcosgriselli): support dual side swipping in one drag.
                if rightToLeftSwipe && translationValue > 0 {
                    self.update(0)
                    return
                } else if !rightToLeftSwipe && translationValue < 0 {
                    self.update(0)
                    return
                }
                
                var fraction = abs(translationValue)
                fraction = min(max(fraction, 0.0), 0.99)
                shouldCompleteTransition = (fraction > 0.5);
                
                self.update(fraction)
            }
            
        case .ended, .cancelled:
            if interactionInProgress {
                interactionInProgress = false
                if !shouldCompleteTransition {
                    if (rightToLeftSwipe && velocity.x < -InteractionConstants.xVelocityForComplete) {
                        shouldCompleteTransition = true
                    } else if (!rightToLeftSwipe && velocity.x > InteractionConstants.xVelocityForComplete) {
                        shouldCompleteTransition = true
                    }
                }
                
                if !shouldCompleteTransition || recognizer.state == .cancelled {
                    cancel()
                } else {
                    // Avoid launching a new transaction while the previous one is finishing.
                    recognizer.isEnabled = false
                    finish()
                    onfinishTransition?()
                }
            }
            
        default : break
        }
    }
    
    /// enables/disables the entire interactor. 
    public var isEnabled = true {
        didSet { panRecognizer?.isEnabled = isEnabled }
    }
    
    /// Checks for the diagonal swipe support. It evaluates if the current gesture is diagonal or Y-Axis based.
    ///
    /// - Parameters:
    ///   - yTranslation: gesture translation on the Y-axis.
    ///   - yVelocity: gesture velocity on the Y-axis.
    /// - Returns: boolean determing wether the interaction should take place or not.
    private func shouldSuspendInteraction(yTranslation: CGFloat, yVelocity: CGFloat) -> Bool {
        if !isDiagonalSwipeEnabled {
            // Cancel interaction if the movement is on the Y axis.
            let isTranslatingOnYAxis = abs(yTranslation) > InteractionConstants.yTranslationForSuspend
            let hasVelocityOnYAxis = abs(yVelocity) > InteractionConstants.yVelocityForSuspend
            
            return isTranslatingOnYAxis || hasVelocityOnYAxis
        }
        return false
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SwipeInteractor: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panRecognizer {
            if let point = panRecognizer?.translation(in: panRecognizer?.view?.superview) {
                return abs(point.x) < InteractionConstants.xTranslationForRecognition
            }
        }
        return true
    }
}
