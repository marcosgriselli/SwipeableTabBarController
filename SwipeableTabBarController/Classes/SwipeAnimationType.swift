//
//  SwipeAnimationType.swift
//  Pods
//
//  Created by Marcos Griselli on 2/1/17.
//
//

import UIKit

enum SwipeAnimationType {
    case overlap
    case sideBySide
    case push
    
    func addTo(containerView: UIView, fromView: UIView, toView: UIView) {
        switch self {
        case .push:
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
        default:
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
        }
    }
    
    func prepare(fromView from: UIView?, toView to: UIView?, direction: Bool) {
        let screenWidth = UIScreen.main.bounds.size.width
        switch self {
        case .overlap:
            to?.frame.origin.x = direction ? -screenWidth : screenWidth
        case .sideBySide:
            from?.frame.origin.x = 0
            to?.frame.origin.x = direction ? -screenWidth : screenWidth
        case .push:
            let scaledWidth = screenWidth/6
            to?.frame.origin.x = direction ? -scaledWidth : scaledWidth
            from?.frame.origin.x = 0
        }
    }
    
    func animation(fromView from: UIView?, toView to: UIView?, direction: Bool) {
        let screenWidth = UIScreen.main.bounds.size.width
        switch self {
        case .overlap:
            to?.frame.origin.x = 0
        case .sideBySide:
            from?.frame.origin.x = direction ? screenWidth : -screenWidth
            to?.frame.origin.x = 0
        case .push:
            to?.frame.origin.x = 0
            from?.frame.origin.x = direction ? screenWidth : -screenWidth
        }
    }
}
