#
# Be sure to run `pod lib lint BGRouterComponent.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BGRouterComponent'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BGRouterComponent.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
组件化工程路由服务工具，用于组件化注册，实现工程组件化
                       DESC

  s.homepage         = 'https://github.com/bingoxu/BGRouterComponent'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bingoxu' => 'bingoxu@yeahka.com' }
  s.source           = { :git => 'https://github.com/bingoxu/BGRouterComponent.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'BGRouterComponent/Classes/**/*'
  
  s.subspec 'BGAnnotator' do |an|
    an.source_files = 'BGRouterComponent/Classes/BGAnnotator/*.{h,m}'
  end
  
  s.subspec 'BGModuleService' do |se|
    se.source_files = 'BGRouterComponent/Classes/BGModuleService/*.{h,m}'
    se.dependency 'BGRouterComponent/BGAnnotator'
  end
  
  s.subspec 'BGRouter' do |ro|
    ro.source_files = 'BGRouterComponent/Classes/BGRouter/*.{h,m}'
    ro.dependency 'BGRouterComponent/BGAnnotator'
  end
  
  # s.resource_bundles = {
  #   'BGRouterComponent' => ['BGRouterComponent/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  # s.dependency 'libextobjc'
  s.dependency 'YYModel'
  
end
