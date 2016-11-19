Pod::Spec.new do |s|

  s.name         = "AXCountingLabel"
  s.version      = "0.2.2"
  s.summary      = "A label shows counting time."
  s.description  = <<-DESC
                    A label shows counting time on iOS platform.
                   DESC

  s.homepage     = "https://github.com/devedbox/AXCountingLabel"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "aiXing" => "862099730@qq.com" }
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/devedbox/AXCountingLabel.git", :tag => "0.2.2" }
  s.source_files  = "AXCountingLabel/AXCountingLabel/*.{h,m}"

  s.frameworks = "UIKit", "Foundation"

  s.requires_arc = true
  s.dependency "pop"

end
