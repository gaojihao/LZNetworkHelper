Pod::Spec.new do |s|
  s.name             = 'LZNetworkHelper'
  s.version          = '0.1.0'
  s.summary          = 'A networking framework base on AFNetworking.'

  s.homepage         = 'https://github.com/gaojihao/LZNetworkHelper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lizhi' => 'lizhi1026@126.com' }
  s.source           = { :git => 'https://github.com/gaojihao/LZNetworkHelper.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.public_header_files = 'LZNetworkHelper/LZNetworkHelper.h'
  s.source_files = 'LZNetworkHelper/*.{h,m}'
  s.dependency 'AFNetworking', '~> 3.0'
end
