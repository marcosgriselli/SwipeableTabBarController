//
//  SwipeTransitioningProtocol.swift
//  Pods
//
//  Created by Marcos Griselli on 2/12/17.
//
//

/// Added to support custom `UIViewControllerAnimatedTransitioning` in different applications.
public protocol SwipeTransitioningProtocol: UIViewControllerAnimatedTransitioning {
    
    /// Direction in which the animation will occur.
    var fromLeft: Bool { get set }

    /// Animation type used.
    var animationType: SwipeAnimationTypeProtocol { get set }
}
