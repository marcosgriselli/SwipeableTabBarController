Pod::Spec.new do |s|
  s.name             = 'SwipeableTabBarController'
  s.version          = '1.0.10'
  s.summary          = 'A UITabBarController where you can swipe interactively between tabs.'

  s.description  = "Subclass of UITabBarController that adds a swipe recognizer to the lowest UIViewController so you can interactively change tabs."

  s.homepage         = 'https://github.com/marcosgriselli/SwipeableTabBarController'

  s.ios.deployment_target = '8.0'
  s.license      = "MIT"

  s.author   	 = "Marcos Griselli"
  s.social_media_url   = "http://twitter.com/marcosgriselli"

  s.source       = { :git => "https://github.com/marcosgriselli/SwipeableTabBarController.git", :tag => "1.0.10" }
  s.source_files  = "SwipeableTabBarController", "SwipeableTabBarController/**/*.{h,m,swift}"
end
