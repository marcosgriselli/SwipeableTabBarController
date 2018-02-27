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
        selectedViewController = viewControllers?[0]
        tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
        setSwipeAnimation(type: SwipeAnimationType.sideBySide)
        setDiagonalSwipe(enabled: true)
    }
}
