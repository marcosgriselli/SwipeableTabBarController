//
//  UIKit+Extensions.swift
//  Pods
//
//  Created by Marcos Griselli on 2/1/17.
//
//

import UIKit

extension UIViewController {
    
    
    /// Get the first controller on a tab stack.
    ///
    /// - Returns: The current tab view controller or the navigation first controller so there's no 
    ///            so there's no interaction with navigation controllers that push other vcs.
    func firstController() -> UIViewController {
        if let navigation = self as? UINavigationController {
            return (navigation.viewControllers.first ?? self)
        }
        return self
    }
}
