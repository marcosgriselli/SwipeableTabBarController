//
//  MapController.swift
//  SwipeableTabBarController
//
//  Created by Marcos Griselli on 3/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import MapKit

class MapController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTabBarSwipe(enabled: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setTabBarSwipe(enabled: true)
    }
}
