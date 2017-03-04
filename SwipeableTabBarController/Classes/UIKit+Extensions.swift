//
//  UIKit+Extensions.swift
//  Pods
//
//  Created by Marcos Griselli on 2/1/17.
//
//

import UIKit

public extension UIViewController {
    
    /// Get the first controller on a navigation stack.
    ///
    /// - Returns: The current tab view controller or the navigation first controller so there's no 
    ///            swipe interaction when the navigation controller pushes a new view controller.
    public func firstController() -> UIViewController {
        if let navigation = self as? UINavigationController {
            return (navigation.viewControllers.first ?? self)
        }
        return self
    }
    
    public func setTabBarSwipe(enabled: Bool) {
        if let swipeTabBarController = tabBarController as? SwipeableTabBarController {
            swipeTabBarController.isSwipeEnabled = enabled
        }
    }
}
