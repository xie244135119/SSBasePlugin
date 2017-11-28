#
#  Be sure to run `pod spec lint SSBasePlugin.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "SSBasePlugin"
  s.version      = "1.2.6"
  s.summary      = "the plugins of SSBase"
  s.description  = "all the plugins ,such as the SSBaseKit, SSBaseLib"

  s.homepage     = "https://github.com/xie244135119/SSBasePlugin/blob/master/README.md"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  s.author       = { "xieqiang" => "xie244135119@163.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/xie244135119/SSBasePlugin.git", :tag => "#{s.version}" }


  # s.source_files  = "SSBasePlugin", "SSBasePlugin/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.default_subspec = 'UMeng'
  s.dependency "SSModuleManager"

  # 友盟
  s.subspec "UMeng" do |st|
    st.source_files="SSBasePlugin/UMeng/*.{h,m}"
    # 友盟统计分析模块
    st.dependency 'UMengAnalytics',  '~>4.1.8'
  end

  #集成极光推送
  s.subspec "ApnsPush" do |st|
    st.source_files="SSBasePlugin/ApnsPush/*.{h,m}"
    # 极光推送
    st.dependency 'JPush', '~>3.0.7'
  end

  #蒲公英测试插件
  s.subspec "Plugin" do |st|
    st.source_files="SSBasePlugin/Pgyer/*.{h,m}"
    #
    s.dependency "SSBaseLib"
  end

end








