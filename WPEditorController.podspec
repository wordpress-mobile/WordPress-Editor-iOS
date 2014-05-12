Pod::Spec.new do |s|
  s.name             = "WPEditorController"
  s.version          = "0.1.0"
  s.summary          = "A simple visual editor for iOS."
  s.description      = <<-DESC
                       WPEditorController is an iOS controller that presents a visual
                       editor. It uses **ARC** and requires no other frameworks.
                       DESC
  s.homepage         = "https://github.com/wordpress-mobile/WPEditorController"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = 'Automattic, Inc.'
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/wordpress-mobile/WPEditorController.git", :tag => "0.1.0" }
  s.source_files = "WPEditorController/*.{h,m}"
  s.requires_arc = true
end
