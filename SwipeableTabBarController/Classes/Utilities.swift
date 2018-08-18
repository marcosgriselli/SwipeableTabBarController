//
//  Utilities.swift
//  SwipeableTabBarController
//
//  Created by Marcos Griselli on 18/08/2018.
//

import Foundation

internal extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    ///
    /// - Parameter index: index of the subscript.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
