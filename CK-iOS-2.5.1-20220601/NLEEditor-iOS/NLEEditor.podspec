#
# Be sure to run `pod lib lint NLEEditor-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NLEEditor'
  s.version          = '0.1.0'
  s.summary          = 'A short description of NLEEditor.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/bytedance/NLEEditor-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bytedance' => 'bytedance@bytedance.com' }
  s.source           = { :git => 'https://github.com/bytedance/NLEEditor-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.ios.library = 'xml2'
  

  s.subspec 'Core' do |ss|
    ss.source_files = 'NLEEditor/Classes/**/*'
    ss.public_header_files = 'NLEEditor/Classes/**/*.h'
    ss.exclude_files = ['NLEEditor/Classes/EditorAdvanced/**/*']
    ss.resource_bundles = {
      'NLEEditor' => ['NLEEditor/Assets/*.xcassets','NLEEditor/Assets/styles/**','NLEEditor/Assets/lottie/**']
    }
    ss.dependency 'lottie-ios'
    ss.dependency 'ReactiveObjC'
    ss.dependency 'NLEPlatform'
    ss.dependency 'TTVideoEditor'
    ss.dependency 'PocketSVG'
    ss.dependency 'MJRefresh'
    ss.dependency 'MJExtension'
    ss.dependency 'KVOController'
    ss.dependency 'SGPagingView'
    ss.dependency 'YYModel'
    ss.dependency 'SDWebImage'
    ss.dependency 'MBProgressHUD'
    ss.dependency 'DVEInject'
    
    ss.prefix_header_contents = <<-EOS
     #ifdef __OBJC__
     #import "DVEUIColorDefines.h"
     #import "DVEUIFontDefines.h"
     #import "DVEUILayoutDefines.h"
     #import "DVEConfigDefines.h"
     #import "DVEMacros.h"
     #endif
    EOS
  end

  s.subspec 'SubTitleRecognize' do |ss|
    ss.source_files = ['NLEEditor/Classes/EditorAdvanced/SubTitleRecognize/**/*']
    ss.dependency 'NLEEditor/Core'
    ss.dependency 'SpeechEngineTts'
    ss.dependency 'ByteDanceKit/Utilities'
    ss.dependency 'BDVCFileUploadClient'
    ss.dependency 'TTNetworkManager'
    ss.dependency 'Heimdallr'
    ss.dependency 'boringssl'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'ENABLE_SUBTITLERECOGNIZE=1'}
  end
  
  s.subspec 'DVEAlbum' do |ss|
    ss.source_files = ['NLEEditor/Classes/EditorAdvanced/DVEAlbum/**/*']
    ss.dependency 'IGListKit'
    ss.dependency 'IGListDiffKit'
    ss.dependency 'Masonry'
    ss.dependency 'MBProgressHUD'
    ss.dependency 'KVOController'
    ss.resource_bundles = {
      'DVEAlbum' => ['NLEEditor/Assets/album/*.xcassets', 'NLEEditor/Assets/album/color/**']
    }
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'ENABLE_DVEALBUM=1'}
  end
  
#  s.subspec 'Adapter' do |ss|
#    ss.dependency 'DVETrackKit/Adapter'
#    ss.dependency 'NLEEditor/Core'
#    ss.dependency 'NLEPlatform/Adapter'
#  end

  s.subspec 'TOBAdapter' do |ss|
    ss.dependency 'NLEEditor/Core'
    ss.dependency 'DVETrackKit'
    ss.dependency 'NLEPlatform'
    #ss.dependency 'DVETrackKit/TOBAdapter'
    #ss.dependency 'NLEPlatform/TOBAdapter'
  end

s.default_subspec = 'TOBAdapter'
end
