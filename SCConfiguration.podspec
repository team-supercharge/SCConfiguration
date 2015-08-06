Pod::Spec.new do |s|
  s.name             = "SCConfiguration"
  s.version          = "1.0.0"
  s.summary          = "With SCConfiguration you can easily read environment-dependent config data from a certain plist file."

  s.homepage         = "https://github.com/team-supercharge/SCConfiguration"
  s.source           = { :git => "https://github.com/team-supercharge/SCConfiguration.git", :tag => s.version.to_s }
  s.license          = { :type => "MIT", :file => "LICENSE" }

  s.author           = { "Supercharge" => "hello@supercharge.io" }
  s.social_media_url = 'https://twitter.com/TeamSupercharge'

  s.platform         = :ios, '6.0'
  s.requires_arc     = true

  s.frameworks       = 'Foundation'
  s.source_files     = 'SCConfiguration/*'
end
