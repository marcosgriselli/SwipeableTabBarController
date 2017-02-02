# SwipeableTabBarController

[![CI Status](http://img.shields.io/travis/marcosgriselli/SwipeableTabBarController.svg?style=flat)](https://travis-ci.org/marcosgriselli/SwipeableTabBarController)
[![Version](https://img.shields.io/cocoapods/v/SwipeableTabBarController.svg?style=flat)](http://cocoapods.org/pods/SwipeableTabBarController)
[![License](https://img.shields.io/cocoapods/l/SwipeableTabBarController.svg?style=flat)](http://cocoapods.org/pods/SwipeableTabBarController)
[![Platform](https://img.shields.io/cocoapods/p/SwipeableTabBarController.svg?style=flat)](http://cocoapods.org/pods/SwipeableTabBarController)

[[https://github.com/marcosgriselli/SwipeableTabBarController/blob/master/SwipeableTabBarController.gif|alt=SwipeableTabBarController]]

## Usage 

If you don't need subclassing `UITabBarController` just set the `UITabBarController` on the Storyboard to be of class `SwipeableTabBarController`.

Otherwise make a sublcass of `SwipeableTabBarController`. Example:

```swift
import SwipeableTabBarController

class TabBarController: SwipeableTabBarController {
    // Do all your subclassing.
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

SwipeableTabBarController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwipeableTabBarController"
```

## Author

[@marcosgriselli](https://twitter.com/marcosgriselli) 

## License

SwipeableTabBarController is available under the MIT license. See the LICENSE file for more info.
