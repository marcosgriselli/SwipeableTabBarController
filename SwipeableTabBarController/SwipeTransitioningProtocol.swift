//
//  SwipeTransitioningProtocol.swift
//  Pods
//
//  Created by Marcos Griselli on 2/12/17.
//
//

import UIKit

/// TODO (marcosgriselli): - Support Obj-c 

/// Added to support custom `UIViewControllerAnimatedTransitioning` in different applications.
public protocol SwipeTransitioningProtocol: UIViewControllerAnimatedTransitioning {

    /// Duration of the transition animation.
    var animationDuration: TimeInterval { get set }

    /// Direction in which the animation will occur.
    var targetEdge: UIRectEdge { get set }

    /// Animation type used.
    var animationType: SwipeAnimationTypeProtocol { get set }

    /// Forces the ongoing transition to reach the end state immediately
    func forceTransitionToFinish() 
}
