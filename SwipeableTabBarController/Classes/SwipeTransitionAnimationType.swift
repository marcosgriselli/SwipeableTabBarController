//
//  SwipeTransitionAnimationType.swift
//  Pods
//
//  Created by Marcos Griselli on 2/1/17.
//
//

import UIKit

enum SwipeTransitionAnimationDirection {
    case leftRight
    case rightLeft
    case unsupported
}

extension SwipeTransitionAnimationDirection {
    init(rectEdge edge: UIRectEdge) {
        switch edge {
        case .right:
            self = .rightLeft
        case .left:
            self = .leftRight
        default:
            self = .unsupported
        }
    }
}

/// Animation Context. This struct contains all actors
/// that participate in the transition.
struct SwipeTransitionAnimationContext {
    /// View that will contain the tabs views that will perform the animation.
    let containerView: UIView
    /// Previously selected tab view.
    let fromView: UIView
    /// New selected tab view.
    let toView: UIView
}

/// Each transition animation type conforms this protocol.
protocol SwipeTransitionAnimation {
    /// Prepare the views prior to the animation start.
    /// - Parameter context: Current context with all views that participates in the transition.
    func prepareForAnimate(withContext context: SwipeTransitionAnimationContext)
    
    /// The animation to take place.
    /// - Parameters:
    ///   - duration: The duration of the animation.
    ///   - direction: The direction of the animation.
    ///   - context: Current context with all views that participates in the transition.
    ///   - completion: Closure called when the animation has been finished.
    func animate(duration: TimeInterval, direction: SwipeTransitionAnimationDirection, context: SwipeTransitionAnimationContext, completion: @escaping (Bool) -> Void)
}

typealias SwipeTransitionAnimationVector = (startPoint: CGPoint, endPoint: CGPoint)

/// Different types of interactive animations.
///
/// - overlap: Previously selected tab will stay in place while the new tab slides in.
/// - sideBySide: Both tabs move side by side as the animation takes place.
/// - push: Replicates iOS default push animation.
public enum SwipeTransitionAnimationType {
    case overlap
    case sideBySide
    case push
    
    private func fromViewAnimationVector(direction: SwipeTransitionAnimationDirection) -> SwipeTransitionAnimationVector? {
        let screenWidth = UIScreen.main.bounds.size.width
        
        switch self {
        case .overlap:
            return nil
        case .push, .sideBySide:
            let endPointX = direction == .rightLeft ? screenWidth : -screenWidth
            return (startPoint: .zero, endPoint: CGPoint(x: endPointX, y: 0))
        }
    }
    
    private func toViewAnimationVector(direction: SwipeTransitionAnimationDirection) -> SwipeTransitionAnimationVector? {
        let screenWidth = UIScreen.main.bounds.size.width
        
        switch self {
        case .overlap, .sideBySide:
            let startPointOriginX = direction == .rightLeft ? -screenWidth : screenWidth
            return (startPoint: CGPoint(x: startPointOriginX, y: 0), endPoint: .zero)
        case .push:
            let scaledWidth = screenWidth / 6
            let startPointOriginX = direction == .rightLeft ? -scaledWidth : scaledWidth
            return (startPoint: CGPoint(x: startPointOriginX, y: 0), endPoint: .zero)
        }
    }
}

extension SwipeTransitionAnimationType: SwipeTransitionAnimation {
    func prepareForAnimate(withContext context: SwipeTransitionAnimationContext) {
        switch self {
        case .overlap, .sideBySide:
            context.containerView.addSubview(context.toView)
        case .push:
            context.containerView.insertSubview(context.toView, belowSubview: context.fromView)
        }
    }
    
    func animate(duration: TimeInterval, direction: SwipeTransitionAnimationDirection, context: SwipeTransitionAnimationContext, completion: @escaping (Bool) -> Void) {
        if let fromViewStartPoint = fromViewAnimationVector(direction: direction)?.startPoint {
            context.fromView.frame.origin.x = fromViewStartPoint.x
        }
        
        if let toViewStartPoint = toViewAnimationVector(direction: direction)?.startPoint {
            context.toView.frame.origin.x = toViewStartPoint.x
        }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
                        
                        if let fromViewEndPoint = self.fromViewAnimationVector(direction: direction)?.endPoint {
                            context.fromView.frame.origin.x = fromViewEndPoint.x
                        }
                        
                        if let toViewEndPoint = self.toViewAnimationVector(direction: direction)?.endPoint {
                            context.toView.frame.origin.x = toViewEndPoint.x
                        }
        }, completion: completion)
    }
}
