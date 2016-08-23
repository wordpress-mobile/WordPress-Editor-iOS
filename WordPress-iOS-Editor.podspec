Pod::Spec.new do |s|
  s.name             = "WordPress-iOS-Editor"
  s.version          = "1.8"
  s.summary      = "Reusable component rich text editor for WordPress.com in an iOS application."

  s.description  = <<-DESC
                   Reusable component for displaying the WordPress.com post editor in an iOS application
                   DESC

  s.homepage     = "http://apps.wordpress.org"
  s.license      = 'GPLv2'
  s.author       = { "Automattic" => "mobile@automattic.com", "Matt Bumgardner" => "matt.bumgardner@automattic.com", "Diego Rey Mendez" => "diego.rey.mendez@automattic.com", "Sergio Estevao" => "sergio@automattic.com" }
  s.source       = { :git => "https://github.com/wordpress-mobile/WordPress-iOS-Editor.git", :tag => s.version.to_s }
  s.social_media_url = 'http://twitter.com/WordPressiOS'
  s.platform     = :ios, '9.0'
  s.source_files = 'Classes'
  s.resources = ["Assets/*.png", "Assets/*.html", "Assets/*.js", "Assets/*.svg", "Assets/*.css", "Assets/*.storyboard", "Assets/*.xib"]
  s.prefix_header_file = "Classes/WordPress-iOS-Editor-Prefix.pch"
  s.exclude_files = 'Classes/exclude'
  s.requires_arc = true
  s.dependency 'CocoaLumberjack', '~> 2.2.0'
  s.dependency 'WordPressCom-Analytics-iOS', '~>0.1.0'
  s.dependency 'NSObject-SafeExpectations', '~>0.0.2'
  s.header_dir = 'WordPressEditor'
end
