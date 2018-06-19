#
# Be sure to run `pod lib lint VPAccordionAnimation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VPAccordionAnimation'
  s.version          = '3.0.1'
  s.summary          = 'Accordion Animation for UITableView cell expansion and collapsing.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a custom class that provides Accordion Animation for cells expanding and collapsing. i.e., expanding or collapsing of cells with auto adjust to center of view. The expanded cell can contain views data or a complete view controller's data.
                       DESC

  s.homepage         = 'https://github.com/varunpm1/VPAccordionAnimation'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'varunpm1' => 'varun.pm@ymedialabs.com' }
  s.source           = { :git => 'https://github.com/varunpm1/VPAccordionAnimation.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'VPAccordionAnimation/Classes/**/*'
  s.swift_version = '4.0'
  
  # s.resource_bundles = {
  #   'VPAccordionAnimation' => ['VPAccordionAnimation/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
