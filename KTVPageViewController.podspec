Pod::Spec.new do |s|
  s.name                = "KTVPageViewController"
  s.version             = "1.0.0"
  s.summary             = "A horizontal scroll view controller."
  s.homepage            = "https://github.com/ChangbaDevs/KTVPageViewController"
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author              = { "Single" => "libobjc@gmail.com" }
  s.social_media_url    = "https://weibo.com/3118550737"
  s.platform            = :ios, "8.0"
  s.source              = { :git => "https://github.com/ChangbaDevs/KTVPageViewController.git", :tag => "#{s.version}" }
  s.source_files        = "KTVPageViewController/*.{h,m}"
  s.public_header_files = "KTVPageViewController/*.h"
  s.frameworks          = "UIKit", "Foundation"
  s.requires_arc        = true
end
