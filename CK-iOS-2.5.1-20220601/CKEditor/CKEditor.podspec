#
# Be sure to run `pod lib lint CKEditor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CKEditor'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CKEditor.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/谢敏/CKEditor'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '谢敏' => 'xiemin.870@bytedance.com' }
  s.source           = { :git => 'https://github.com/谢敏/CKEditor.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CKEditor/Classes/**/*'
  
  s.dependency 'NLEEditor/TOBAdapter'
  s.dependency 'NLEEditor/DVEAlbum'
  s.dependency 'Masonry'
  s.dependency 'lottie-ios'
  s.dependency 'YYWebImage'
  s.dependency 'MJExtension'
  s.dependency 'Toast'
  s.dependency 'ReactiveObjC'
  s.dependency 'YYModel'

  s.prefix_header_contents = "#import <CKEditor/CKEditorHeader.h>"
  
  s.resource_bundles = {
    'CKEditor' => ['CKEditor/Assets/**/*']
  }
  
if ENV['CV_USE_CK']
    s.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'BEF_USE_CK=1'
    }
end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
