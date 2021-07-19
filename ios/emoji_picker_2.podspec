#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint emoji_picker.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'emoji_picker_2'
  s.version          = '0.1.0'
  s.summary          = 'Keyboard-style emoji picker with skin colors'
  s.description      = <<-DESC
An improvement on https://pub.dev/packages/emoji_picker. Now with skin color picking, fast loading speed and more D.R.Y.
                       DESC
  s.homepage         = 'http://github.com/Franchovy/emoji_picker_2'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'widgletlib@pm.me' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
