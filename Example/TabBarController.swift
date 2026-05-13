//
//  TabBarController.swift
//  SwipeableTabBarController
//
//  Created by Marcos Griselli on 2/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import SwipeableTabBarController
import UIKit

class TabBarController: SwipeableTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewControllers = viewControllers {
            selectedViewController = viewControllers[1]
        }
        
        /// Set the animation type for swipe
        swipeAnimatedTransitioning?.animationType = SwipeAnimationType.sideBySide
        
        /// Set the animation type for tap
        tapAnimatedTransitioning?.animationType = SwipeAnimationType.push

        /// if you want cycling switch tab, set true 'isCyclingEnabled'
        isCyclingEnabled = true

        /// Disable custom transition on tap.
        //tapAnimatedTransitioning = nil
        
        /// Set swipe to only work when strictly horizontal.
//        diagonalSwipeEnabled = true

        if ProcessInfo.processInfo.arguments.contains("StressSelectedIndexTransitions") {
            stressSelectedIndexTransitions()
        }
    }

    private func stressSelectedIndexTransitions() {
        var transitionCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            guard transitionCount < 10 else {
                timer.invalidate()
                return
            }

            self.selectedIndex = abs(self.selectedIndex - 1)
            transitionCount += 1
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Handle didSelect viewController method here
    }
}
