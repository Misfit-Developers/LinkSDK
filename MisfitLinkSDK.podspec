#
# Be sure to run `pod lib lint MisfitLinkSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = "MisfitLinkSDK"
s.version          = "0.1.0"
s.summary          = "Gain access to button events from the Misfit Flash"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
s.description      = <<-DESC
The Misfit Link SDK gives your application access to the button command feature of the Misfit Flash, allowing users to control your application from the wrist.
DESC

s.homepage         = "https://github.com/Misfit-Developers/LinkSDK.git"
# s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
s.license          = 'MIT'
s.author           = { "Phill Pasqual" => "phill@misfit.com" }
s.source           = { :git => "https://github.com/Misfit-Developers/LinkSDK.git", :tag => s.version.to_s }

s.platform     = :ios, '7.0'
s.requires_arc = true

s.preserve_paths = "Pod/MisfitLinkSDK.framework"
s.vendored_frameworks = "Pod/MisfitLinkSDK.framework"
s.public_header_files = "Pod/MisfitLinkSDK.framework/Versions/A/Headers/*.h"

end
