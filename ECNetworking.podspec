#
# Be sure to run `pod lib lint ECNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ECNetworking'
  s.version          = '0.1.0'
  s.summary          = 'A library with a simple interface for sending, receiving & managing requests.'
  s.description      = 'A library with a simple interface for sending, receiving & managing requests.
                        Creating requests and defining what their response looks like can be done in a few lines.
                        Managing complicated workflows like authentication is made easy with request Actions'
  s.homepage         = 'https://github.com/EvanCooper9/ECNetworking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'EvanCooper9' => 'evan.cooper@rogers.com' }
  s.source           = { :git => 'https://github.com/EvanCooper9/ECNetworking.git', :tag => s.version.to_s }
  s.social_media_url = 'https://evancooper.tech'
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.3'
  s.source_files = 'ECNetworking/**/*'
  s.dependency 'RxSwift'
end
