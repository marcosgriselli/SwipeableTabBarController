//
//  TabBarController.swift
//  SwipeableTabBarController
//
//  Created by Marcos Griselli on 2/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import SwipeableTabBarController

class TabBarController: SwipeableTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 1
        
        /// Set the animation type for swipe
        setSwipeAnimation(type: SwipeAnimationType.sideBySide)
        /// Set the animation type for tap
        setTapAnimation(type: SwipeAnimationType.sideBySide)
    
        /// Disable custom transition on tap.
//        setTapTransitioning(transition: nil)
        
        /// Set swipe to only work when strictly horizontal.
        setDiagonalSwipe(enabled: false)
    }
}
