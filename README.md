# SwipeableTabBarController

[![Version](https://img.shields.io/cocoapods/v/SwipeableTabBarController.svg?style=flat)](http://cocoapods.org/pods/SwipeableTabBarController)
[![License](https://img.shields.io/cocoapods/l/SwipeableTabBarController.svg?style=flat)](http://cocoapods.org/pods/SwipeableTabBarController)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

<a href="url"><img src="./GIFs/SwipeableTabBarController.gif" height="650" width="375" ></a><br />

## Usage

If you don't need subclassing `UITabBarController` just set the `UITabBarController` on the Storyboard to be of type `SwipeableTabBarController`.

Otherwise make a sublcass of `SwipeableTabBarController`.

Example:

```swift
import SwipeableTabBarController

class TabBarController: SwipeableTabBarController {
    // Do all your subclassing as a regular UITabBarController.
}
```

### Animations

`SwipeableTabBarController` supports 3 different types of animations out of the box. Setting the desired animation is easy. On your `SwipeableTabBarController` subclass just do:

```swift
setSwipeAnimation(type: SwipeAnimationType.push)
```

If you are supporting just one type of animation call it on `viewDidLoad()` otherwise call it as you need to change the desired animation.

** Side by Side (default) **

<a href="url"><img src="./GIFs/SideBySideAnimation.gif" height="216" width="125" ></a>

The default animation is `SwipeAnimationType.sideBySide` where the newly selected tab will move in at the same speed the previous one moves out.

** Overlap **

<a href="url"><img src="./GIFs/OverlapAnimation.gif" height="216" width="125" ></a>

`SwipeAnimationType.overlap` the newly selected tab will move in to take the central place on top of the previous one which will hold it's position.

** Push **

<a href="url"><img src="./GIFs/PushAnimation.gif" height="216" width="125" ></a>

`SwipeAnimationType.push` follows iOS default push animation where the top view moves away while the bottom one slightly moves behind. In this case the top view will be the previously selected tab view.

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
