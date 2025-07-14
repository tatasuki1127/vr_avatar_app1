Pod::Spec.new do |spec|
  spec.name                     = 'UnityFramework'
  spec.version                  = '2022.3.21'
  spec.summary                  = 'Unity as Library Framework for iOS'
  spec.description              = 'Unity Framework exported as Library for iOS integration with Flutter'
  spec.homepage                 = 'https://unity.com'
  spec.license                  = { :type => 'Unity', :file => 'LICENSE' }
  spec.author                   = { 'Unity Technologies' => 'support@unity3d.com' }
  spec.source                   = { :path => '.' }
  
  spec.ios.deployment_target    = '15.0'
  spec.requires_arc             = true
  
  # Framework configuration
  spec.vendored_frameworks      = 'UnityFramework.framework'
  spec.preserve_paths           = 'UnityFramework.framework'
  
  # Headers
  spec.public_header_files      = 'UnityFramework.framework/Headers/**/*.h'
  spec.source_files             = 'UnityFramework.framework/Headers/**/*.h'
  
  # Module map
  spec.module_map               = 'UnityFramework.framework/Modules/module.modulemap'
  
  # Static libraries
  spec.vendored_libraries       = '../../Libraries/libiPhone-lib.a', '../../Libraries/baselib.a', '../../Libraries/libUnityARKit.a'
  
  # System frameworks (including missing AudioToolbox and AVFoundation)
  spec.frameworks               = 'AudioToolbox', 'AVFoundation', 'Metal', 'CoreGraphics', 'CoreImage', 'ImageIO', 'QuartzCore', 'UIKit', 'Foundation', 'MetalKit', 'CoreVideo', 'Accelerate', 'Security', 'SystemConfiguration', 'CoreText'
  spec.libraries                = 'c++', 'z'
  spec.weak_frameworks          = 'ARKit', 'CoreML', 'GameController'
  
  # Build settings
  spec.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS'    => '$(inherited) $(PODS_TARGET_SRCROOT)',
    'LIBRARY_SEARCH_PATHS'      => '$(inherited) $(PODS_TARGET_SRCROOT)/../../Libraries',
    'OTHER_LDFLAGS'             => '$(inherited) -framework UnityFramework -ObjC',
    'ENABLE_BITCODE'            => 'NO',
    'IPHONEOS_DEPLOYMENT_TARGET' => '15.0'
  }
  
  spec.user_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS'    => '$(inherited) $(PODS_TARGET_SRCROOT)',
    'LIBRARY_SEARCH_PATHS'      => '$(inherited) $(PODS_TARGET_SRCROOT)/../../../Libraries',
    'OTHER_LDFLAGS'             => '$(inherited) -framework UnityFramework -ObjC',
    'ENABLE_BITCODE'            => 'NO'
  }
end