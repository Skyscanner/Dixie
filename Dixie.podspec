Pod::Spec.new do |s|

  s.name         = "Dixie"
  s.version      = "1.0"
  s.summary      = "An alternative mocking framework."
  s.license      = "Apache License 2.0"
  s.homepage     = "https://medium.com/@Skyscanner/dixie-turning-chaos-to-your-advantage-4f3749e6d485"

  s.author       = { "Peter Adam Wiesner" => "peter.wiesner@skyscanner.net", "Zsolt Varnai" => "zsolt.varnai@skyscanner.net", "Csaba Szabo" => "csaba.szabo@skyscanner.net", "Zsombor Fuszenecker" => "zsombor.fuszenecker@skyscanner.net"}

  s.platform     = :ios

  s.source       = { :git => "https://github.com/Skyscanner/Dixie.git", tag:s.version.to_s}

  s.source_files  = "Dixie/Dixie/**/*.{h,m}"
  s.public_header_files = "Dixie/Dixie/**/*.h"
  s.requires_arc = true
  
end