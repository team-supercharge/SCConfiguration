Pod::Spec.new do |s|
  s.name                = "SCConfiguration"
  s.version             = "2.0.1"
  s.summary             = "With SCConfiguration you can easily manage encrypted, environment dependent (or global) configuration parameters in a property list file."

  s.homepage            = "https://github.com/team-supercharge/SCConfiguration"
  s.source              = { :git => "https://github.com/team-supercharge/SCConfiguration.git", :tag => s.version.to_s }
  s.license             = { :type => "MIT", :file => "LICENSE" }

  s.author              = { "Supercharge" => "hello@supercharge.io" }
  s.social_media_url    = 'https://twitter.com/TeamSupercharge'

  s.platform            = :ios, '6.0'
  s.requires_arc        = true

  s.source_files        = 'Pod/Classes/**/*'
  s.public_header_files = 'Pod/Classes/**/*.h'

  s.frameworks          = 'Foundation'

  s.dependency            'RNCryptor', '~> 2.0'
end
