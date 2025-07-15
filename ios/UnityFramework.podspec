Pod::Spec.new do |spec|
  spec.name = "UnityFramework"
  spec.version = "2022.3.21"
  spec.summary = "Unity Framework for Flutter"
  spec.description = "Unity Framework with reliable structure and real Unity components"
  spec.homepage = "https://unity.com"
  spec.license = { :type => "Unity" }
  spec.author = { "Unity" => "support@unity3d.com" }
  spec.source = { :path => "." }
  spec.ios.deployment_target = "15.0"
  spec.requires_arc = true
  
  # 重要: module_name を明示
  spec.module_name = "UnityFramework"
  
  spec.vendored_frameworks = "Frameworks/UnityFramework.framework"
  
  spec.preserve_paths = ["Frameworks/**/*"]
  spec.public_header_files = "Frameworks/UnityFramework.framework/Headers/**/*.h"
  spec.source_files = "Frameworks/UnityFramework.framework/Headers/**/*.h"
  spec.module_map = "Frameworks/UnityFramework.framework/Modules/module.modulemap"
  
  spec.frameworks = [
    "Foundation", "UIKit", "Metal", "AudioToolbox",
    "AVFoundation", "CoreGraphics", "QuartzCore",
    "OpenGLES", "GLKit", "CoreMotion", "SystemConfiguration",
    "Security", "CFNetwork", "CoreTelephony", "CoreMedia",
    "CoreVideo", "Accelerate", "GameController"
  ]
  
  spec.libraries = ["c++", "z", "sqlite3", "compression"]
  spec.weak_frameworks = ["ARKit", "CoreML", "MetalKit", "MetalPerformanceShaders"]
  
  spec.pod_target_xcconfig = {
    "ENABLE_BITCODE" => "NO",
    "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES",
    "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) UNITY_IOS=1 UNITY_HYBRID=1",
    "VALID_ARCHS" => "arm64",
    "ARCHS" => "arm64",
    "ONLY_ACTIVE_ARCH" => "NO",
    "OTHER_LDFLAGS" => [
      "$(inherited)",
      "-ObjC"
    ]
  }
  
  spec.user_target_xcconfig = {
    "ENABLE_BITCODE" => "NO",
    "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES",
    "VALID_ARCHS" => "arm64",
    "ARCHS" => "arm64",
    "OTHER_LDFLAGS" => [
      "$(inherited)",
      "-ObjC"
    ]
  }
end