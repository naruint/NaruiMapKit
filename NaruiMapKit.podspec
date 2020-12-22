#
# Be sure to run `pod lib lint NaruiMapKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NaruiMapKit'
  s.version          = '0.1.7'
  s.summary          = 'Narui Map Kit'
  s.description      = '키워드로 지도 검색 등을 사용하기 위한 라이브러리'
  s.homepage         = 'https://github.com/naruint/NaruiMapKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '서창열' => 'kongbaguni@gmail.com' }
  s.source           = { :git => 'https://github.com/naruint/NaruiMapKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/kongbaguni'

  s.ios.deployment_target = '12.0'

  s.source_files = 'NaruiMapKit/Classes/**/*'
  
  s.resource_bundles = {
      'NaruiMapKit' => ['NaruiMapKit/Assets/**/**/*']
  }
  s.resources = 'NaruiMapKit/Assets/*.{xib,storyboard,xcassets}'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit', 'CoreLocation'
  s.dependency 'Alamofire'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'NaruiUIComponents'

end
