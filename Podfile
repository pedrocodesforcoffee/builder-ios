# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

use_frameworks!

target 'BobTheBuilder' do
  # Networking
  # pod 'Alamofire', '~> 5.8'

  # UI Components
  # pod 'SnapKit', '~> 5.6'
  # pod 'Kingfisher', '~> 7.10'

  # Analytics & Monitoring
  # pod 'Firebase/Analytics'
  # pod 'Firebase/Crashlytics'

  # Utilities
  # pod 'SwiftLint'

  target 'BobTheBuilderTests' do
    inherit! :search_paths
    # Pods for testing
    # pod 'Quick', '~> 7.0'
    # pod 'Nimble', '~> 12.0'
  end

  target 'BobTheBuilderUITests' do
    # Pods for UI testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
