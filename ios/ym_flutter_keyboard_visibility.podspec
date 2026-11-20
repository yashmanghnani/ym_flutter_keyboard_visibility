#
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ym_flutter_keyboard_visibility.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ym_flutter_keyboard_visibility'
  s.version          = '1.1.1'
  s.summary          = 'Observe keyboard visibility changes in Flutter.'
  s.description      = <<-DESC
Observe soft-keyboard visibility changes from Flutter on iOS.
                       DESC
  s.homepage         = 'https://github.com/yashmanghnani/ym_flutter_keyboard_visibility'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Jason Rai' => 'jason.c.rai@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency       'Flutter'
  s.platform         = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version    = '5.0'
end
