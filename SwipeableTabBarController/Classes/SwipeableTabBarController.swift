//
//  SwipeableTabBarController.swift
//  SwipeableTabBarController
//
//  Created by Marcos Griselli on 1/26/17.
//  Copyright © 2017 Marcos Griselli. All rights reserved.
//

import UIKit 

/// `UITabBarController` subclass with a `selectedViewController` property observer,
/// `SwipeInteractor` that handles the swiping between tabs gesture, and a `SwipeTransitioningProtocol`
/// that determines the animation to be added. Use it or subclass it.
@objc(SwipeableTabBarController)
open class SwipeableTabBarController: UITabBarController {

    /// Animated transition to be performed while swiping
    private(set) public var swipeAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeTransitionAnimator()
    
    /// Animated transition to be performed when tapping on a tabbar item
    private(set) public var tapAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeTransitionAnimator()
    
    /// Animated transition being used currently
    private var currentAnimatedTransitioningType: SwipeTransitioningProtocol?
    
    /// Pan gesture for the swiping interaction
    //swiftlint:disable next implicitly_unwrapped_optional
    private var panGestureRecognizer: UIPanGestureRecognizer!

    @available(*, deprecated, message: "For the moment the diagonal swipe configuration is not available.")
    /// Toggle the diagonal swipe to remove the just `perfect` horizontal swipe interaction
    /// needed to perform the transition.
    open var diagonalSwipeEnabled = true

    /// Enables/Disables swipes on the tabbar controller.
    open var isSwipeEnabled = true {
        didSet { panGestureRecognizer.isEnabled = isSwipeEnabled }
    }

    /// Enables/Disables cycling swipes on the tabBar controller. default value is 'false'
    open var isCyclingEnabled = false

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    private func setup() {
        // UITabBarControllerDelegate for transitions.
        delegate = self
        currentAnimatedTransitioningType = tapAnimatedTransitioning
        // Gesture setup
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerDidPan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    @IBAction func panGestureRecognizerDidPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            currentAnimatedTransitioningType = tapAnimatedTransitioning
        }
        // Do not attempt to begin an interactive transition if one is already
        // ongoing
        if transitionCoordinator != nil {
            return
        }
        
        if sender.state == .began {
            currentAnimatedTransitioningType = swipeAnimatedTransitioning
        }

        if sender.state == .began || sender.state == .changed {
            beginInteractiveTransitionIfPossible(sender)
        }
    }
    
    /// Asks whether the given view controll should get selected during an interactive
    /// transition.
    @objc dynamic open func swipeableTabBarController(_ tabBarController: SwipeableTabBarController, shouldSelectInteractively viewController: UIViewController) -> Bool {
        // By default, just ask the normal tab bar delegate whether the view controller
        // may be selected.
        return delegate?.tabBarController?(tabBarController, shouldSelect: viewController)
            ?? true
    }
    
    /// Starts the transition by changing the selected index if the
    /// gesture allows it.
    ///
    /// - Parameter sender: gesture recognizer
    private func beginInteractiveTransitionIfPossible(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let candidateIndex: Int?
        
        if translation.x > 0.0 {
            // Panning right, transition to the left view controller.
            candidateIndex = indexForDirection(.left)
        } else if translation.x < 0.0 && selectedIndex + 1 < viewControllers?.count ?? 0 {
            // Panning left, transition to the right view controller.
            candidateIndex = indexForDirection(.right)
        } else {
            candidateIndex = nil
        }
        
        if let targetIndex = candidateIndex {
            selectedIndex = targetIndex
        } else {
            // Don't reset the gesture recognizer if we skipped starting the
            // transition because we don't have a translation yet (and thus, could
            // not determine the transition direction).
            if !translation.equalTo(CGPoint.zero) {
                // There is not a view controller to transition to, force the
                // gesture recognizer to fail.
                sender.isEnabled = false
                sender.isEnabled = true
            }
        }
        
        transitionCoordinator?.animate(alongsideTransition: nil) { [unowned self] context in
            if context.isCancelled && sender.state == .changed {
                self.beginInteractiveTransitionIfPossible(sender)
            }
        }
    }
    
    /// Determines the next index that may be selected for a given direction.
    ///
    /// - Parameter direction: Direction in which to search. Only `.left` and
    ///   `.right` are supported.
    /// - Returns: An index to select or `nil` if no valid index was found.
    private func indexForDirection(_ direction: UIRectEdge) -> Int? {
        let delta: Int

        // Derive value to add to/subtract from the index for the given direction.
        switch direction {
        case .left:
            delta = -1
            
        case .right:
            delta = 1
            
        default:
            return nil
        }
        
        // Check whether the view controller is in a state where we have a chance
        // of deriving a meaningful value.
        guard
            let viewControllers = self.viewControllers,
            viewControllers.count >= 2,
            selectedIndex != NSNotFound
        else { return nil }
        
        var candidateIndex = selectedIndex
        let startController = viewControllers[candidateIndex]
        
        repeat {
            // Advance to the next index, if possible.
            candidateIndex += delta
            if candidateIndex < 0 {
                if isCyclingEnabled {
                    candidateIndex = viewControllers.count - 1
                } else {
                    return nil
                }
            } else if candidateIndex >= viewControllers.count {
                if isCyclingEnabled {
                    candidateIndex = 0
                } else {
                    return nil
                }
            }
            
            let candidate = viewControllers[candidateIndex]
            // If we arrived back at the start there's no selectable view controller.
            guard candidate != startController else { return nil }
            
            // Check whether we want the view controller to be selected.
            if self.swipeableTabBarController(self, shouldSelectInteractively: candidate) {
                return candidateIndex
            }
        } while true
    }
    
}

// MARK: - UITabBarControllerDelegate
extension SwipeableTabBarController: UITabBarControllerDelegate {

    open func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Get the indexes of the ViewControllers involved in the animation to determine the animation flow.
        guard let fromVCIndex = tabBarController.viewControllers?.index(of: fromVC),
            let toVCIndex = tabBarController.viewControllers?.index(of: toVC) else {
                return nil
        }
        var edge: UIRectEdge = fromVCIndex > toVCIndex ? .right : .left

        let controllersCount = viewControllers?.count ?? 0
        if isCyclingEnabled && fromVCIndex == controllersCount - 1 && toVCIndex == 0 {
            edge = .left
        } else if isCyclingEnabled && fromVCIndex == 0 && toVCIndex == controllersCount - 1 {
            edge = .right
        }

        currentAnimatedTransitioningType?.targetEdge = edge
        return currentAnimatedTransitioningType
    }

    open func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            return SwipeInteractor(gestureRecognizer: panGestureRecognizer, edge: currentAnimatedTransitioningType?.targetEdge ?? .right)
        } else {
            return nil
        }
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return transitionCoordinator == nil 
    }
}
