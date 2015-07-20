#
#  Be sure to run `pod spec lint NDRefresh.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "NDRefresh"
  s.version      = "0.1"
  s.summary      = "Flexible pull to refresh control for iOS, written in Swift."
  s.homepage     = "https://github.com/Nextdoor/NDRefresh"
  s.license      = { :type => "Apache", :file => "LICENSE.txt" }
  s.authors      = "Wenbin Fang", "Daisuke Fujiwara"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Nextdoor/NDRefresh.git", :tag => "v0.1" }
  s.source_files  = "NDRefresh/NDRefresh/*.swift" 
end
