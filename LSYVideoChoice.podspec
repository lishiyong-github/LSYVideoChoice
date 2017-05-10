
Pod::Spec.new do |s|

s.name = "LSYVideoChoice"

s.version = "1.0.0.0"

s.summary = "A Library for iOS LSYVideoChoice."

s.homepage = "https://github.com/lishiyong-github/LSYVideoChoice"

s.license = "MIT"

s.author = { "lishiyong-github" => "1525846137@qq.com" }

s.source = { :git => "https://github.com/lishiyong-github/LSYVideoChoice.git", :tag => s.version }

s.source_files = "LSYVideoChoice/*.{h,m}"

s.framework = ['UIKit','MobileCoreServices','AssetsLibrary','AVFoundation']

s.ios.deployment_target = '8.0'

s.platform = :ios,"7.0"

end
