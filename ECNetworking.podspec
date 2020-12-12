#
# Be sure to run `pod lib lint ECNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ECNetworking'
  s.version          = '1.2.2'
  s.summary          = 'A simple swifty networking layer.'
  s.description      = 'A simple swifty networking layer. Supports custom interceptions.'
  s.homepage         = 'https://github.com/EvanCooper9/ECNetworking'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'EvanCooper9' => 'evan.cooper@rogers.com' }
  s.source           = { :git => "#{s.homepage}.git", :tag => "v#{s.version}" }
  s.social_media_url = 'https://evancooper.tech'
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.3'
  s.source_files = 'Sources/**/*'
end
