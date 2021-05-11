Pod::Spec.new do |s|
  s.name             = 'ECNetworking'
  s.version          = ENV['RELEASE_VERSION'] || 2.0
  s.summary          = 'A simple swifty networking layer.'
  s.description      = 'A simple swifty networking layer. Supports custom interceptions.'
  s.homepage         = 'https://github.com/EvanCooper9/ECNetworking'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'EvanCooper9' => 'evan.cooper@rogers.com' }
  s.source           = { :git => "#{s.homepage}.git", :tag => "#{s.version}" }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.5'
  s.source_files = 'Sources/**/*'
end
