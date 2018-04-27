//
//  SwipeTransitioningProtocol.swift
//  Pods
//
//  Created by Marcos Griselli on 2/12/17.
//
//

import UIKit

/// Added to support custom `UIViewControllerAnimatedTransitioning` in different applications.
public protocol SwipeTransitioningProtocol: UIViewControllerAnimatedTransitioning {

    /// Direction in which the animation will occur.
    var fromLeft: Bool { get set }

    /// Animation type used.
    var animationType: SwipeAnimationTypeProtocol { get set }

    /// Indicates if the transition has started.
    var transitionStarted: Bool { get set }
}
