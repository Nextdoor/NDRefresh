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
  s.description  = <<-DESC
                   A longer description of NDRefresh in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC
  s.homepage     = "https://github.com/Nextdoor/NDRefresh"
  s.license      = { :type => "Apache", :file => "LICENSE.txt" }
  s.authors      = "Wenbin Fang", "Daisuke Fujiwara"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Nextdoor/NDRefresh.git", :tag => "v0.1" }
  s.source_files  = "NDRefresh/NDRefresh/*" 
end
