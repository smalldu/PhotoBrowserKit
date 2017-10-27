#
# Be sure to run `pod lib lint PhotoBrowserKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PhotoBrowserKit'
  s.version          = '0.1.6'
  s.summary          = 'A short description of PhotoBrowserKit.'
  s.homepage         = 'https://github.com/smalldu/PhotoBrowserKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'smalldu' => '363958265@qq.com' }
  s.source           = { :git => 'https://github.com/smalldu/PhotoBrowserKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '8.0'
  s.source_files = 'PhotoBrowserKit/Classes/**/*'
  # s.resource_bundles = {
  #   'PhotoBrowserKit' => ['PhotoBrowserKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'Kingfisher', '~> 3.1.0'
end
