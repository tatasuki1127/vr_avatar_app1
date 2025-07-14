#!/bin/bash
# 既存の設定を継続
echo "BUILD_LIBRARY_FOR_DISTRIBUTION=NO" > $XCODE_XCCONFIG_FILE

# dSYM生成のための設定を追加
echo "DEBUG_INFORMATION_FORMAT=dwarf-with-dsym" >> $XCODE_XCCONFIG_FILE
echo "ENABLE_BITCODE=NO" >> $XCODE_XCCONFIG_FILE
echo "ENABLE_DSYM_FILE=YES" >> $XCODE_XCCONFIG_FILE

echo "Ensuring dSYM generation is enabled"
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks `sysctl -n hw.ncpu`
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentLinkTasks `sysctl -n hw.ncpu`
defaults write com.apple.dt.Xcode BuildSystemScheduleInherentlyParallelCommandsExclusively -bool NO

# Flutter clean 強制実行
echo "Cleaning Flutter cache..."
flutter clean

# Unity Framework 自動展開
echo "Starting Unity Framework extraction..."

# iOS ディレクトリに移動
cd ios

# Pods キャッシュクリア
echo "Cleaning Pods cache..."
rm -rf Pods
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

# Unity Framework zip の存在確認と展開
if [ -f "UnityFramework.zip" ]; then
    echo "Found UnityFramework.zip"
    echo "Zip size: $(du -sh UnityFramework.zip)"

    # 既存の Framework ディレクトリを削除（クリーンアップ）
    if [ -d "Frameworks" ]; then
        echo "Removing existing Frameworks directory"
        rm -rf Frameworks
    fi

    # Unity Framework を展開
    echo "Extracting UnityFramework.zip..."
    unzip -o UnityFramework.zip

    # パス問題を修正: 深いディレクトリ構造を正しい場所に移動
    if [ -d "mnt/c/Users/nndds/StudioProjects/vr_avatar_app/ios/Frameworks" ]; then
        echo "Moving extracted framework to correct location..."
        mv "mnt/c/Users/nndds/StudioProjects/vr_avatar_app/ios/Frameworks" "./"
        rm -rf "mnt"
        echo "Unity Framework moved successfully!"
    elif [ -d "Frameworks" ]; then
        echo "Unity Framework already in correct location!"
    else
        echo "Unity Framework not found after extraction!"
        exit 1
    fi

    # Unity Static Libraries 自動展開
    echo "Starting Unity Static Libraries extraction..."
    
    if [ -f "UnityLibraries.zip" ]; then
        echo "Found UnityLibraries.zip"
        echo "Zip size: $(du -sh UnityLibraries.zip)"
        
        # 既存の Libraries ディレクトリを削除（クリーンアップ）
        if [ -d "Libraries" ]; then
            echo "Removing existing Libraries directory"
            rm -rf Libraries
        fi
        
        # Libraries ディレクトリを作成
        mkdir -p Libraries
        
        # Unity Libraries を展開
        echo "Extracting UnityLibraries.zip..."
        unzip -o UnityLibraries.zip -d Libraries/
        
        # 展開された静的ライブラリの確認
        echo "Verifying extracted libraries:"
        if [ -f "Libraries/libiPhone-lib.a" ]; then
            echo "- libiPhone-lib.a: $(du -sh Libraries/libiPhone-lib.a)"
        else
            echo "- libiPhone-lib.a: MISSING"
            exit 1
        fi
        
        if [ -f "Libraries/baselib.a" ]; then
            echo "- baselib.a: $(du -sh Libraries/baselib.a)"
        else
            echo "- baselib.a: MISSING"
            exit 1
        fi
        
        if [ -f "Libraries/libUnityARKit.a" ]; then
            echo "- libUnityARKit.a: $(du -sh Libraries/libUnityARKit.a)"
        else
            echo "- libUnityARKit.a: MISSING"
            exit 1
        fi
        
        echo "Unity Static Libraries extraction completed successfully!"
        
    else
        echo "UnityLibraries.zip not found!"
        echo "Static libraries must be manually provided"
        exit 1
    fi

    # プロジェクトルートに戻る
    cd ..

    # Headers ディレクトリを確実に作成
    mkdir -p "ios/Frameworks/UnityFramework.framework/Headers"
    mkdir -p "ios/Frameworks/UnityFramework.framework/Modules"

    echo "Restoring critical header files from Git repository..."

    # UnityAppController.h を復元
    TARGET_FILE="ios/Frameworks/UnityFramework.framework/Headers/UnityAppController.h"
    if git show HEAD:ios/Frameworks/UnityFramework.framework/Headers/UnityAppController.h > "$TARGET_FILE" 2>/dev/null; then
        echo "UnityAppController.h: Restored from Git"
    else
        echo "UnityAppController.h: Not found in Git - creating minimal version"
        echo '#pragma once' > "$TARGET_FILE"
        echo '#import <UIKit/UIKit.h>' >> "$TARGET_FILE"
        echo '@interface UnityAppController : NSObject<UIApplicationDelegate>' >> "$TARGET_FILE"
        echo '@end' >> "$TARGET_FILE"
    fi

    # LifeCycleListener.h を復元/作成（新規追加）
    TARGET_FILE="ios/Frameworks/UnityFramework.framework/Headers/LifeCycleListener.h"
    if git show HEAD:ios/Frameworks/UnityFramework.framework/Headers/LifeCycleListener.h > "$TARGET_FILE" 2>/dev/null; then
        echo "LifeCycleListener.h: Restored from Git"
    else
        echo "LifeCycleListener.h: Not found in Git - creating minimal version"
        echo '#pragma once' > "$TARGET_FILE"
        echo '#import <Foundation/Foundation.h>' >> "$TARGET_FILE"
        echo '@protocol LifeCycleListener <NSObject>' >> "$TARGET_FILE"
        echo '@optional' >> "$TARGET_FILE"
        echo '- (void)didBecomeActive:(NSNotification*)notification;' >> "$TARGET_FILE"
        echo '- (void)willResignActive:(NSNotification*)notification;' >> "$TARGET_FILE"
        echo '- (void)didEnterBackground:(NSNotification*)notification;' >> "$TARGET_FILE"
        echo '- (void)willEnterForeground:(NSNotification*)notification;' >> "$TARGET_FILE"
        echo '- (void)willTerminate:(NSNotification*)notification;' >> "$TARGET_FILE"
        echo '@end' >> "$TARGET_FILE"
    fi

    # RenderPluginDelegate.h を復元
    TARGET_FILE="ios/Frameworks/UnityFramework.framework/Headers/RenderPluginDelegate.h"
    if git show HEAD:ios/Frameworks/UnityFramework.framework/Headers/RenderPluginDelegate.h > "$TARGET_FILE" 2>/dev/null; then
        echo "RenderPluginDelegate.h: Restored from Git"
    else
        echo "RenderPluginDelegate.h: Not found in Git - creating minimal version"
        echo '#pragma once' > "$TARGET_FILE"
        echo '#import <UnityFramework/LifeCycleListener.h>' >> "$TARGET_FILE"
        echo '@protocol RenderPluginDelegate <LifeCycleListener, NSObject>' >> "$TARGET_FILE"
        echo '@required' >> "$TARGET_FILE"
        echo '- (void)mainDisplayInited:(void*)surface;' >> "$TARGET_FILE"
        echo '@end' >> "$TARGET_FILE"
    fi

    # UnityFramework.h を復元
    TARGET_FILE="ios/Frameworks/UnityFramework.framework/Headers/UnityFramework.h"
    if git show HEAD:ios/Frameworks/UnityFramework.framework/Headers/UnityFramework.h > "$TARGET_FILE" 2>/dev/null; then
        echo "UnityFramework.h: Restored from Git"
    else
        echo "UnityFramework.h: Not found in Git - creating minimal version"
        echo '#import <UIKit/UIKit.h>' > "$TARGET_FILE"
        echo '#import <Foundation/Foundation.h>' >> "$TARGET_FILE"
        echo '#import <UnityFramework/UnityAppController.h>' >> "$TARGET_FILE"
        echo '@interface UnityFramework : NSObject' >> "$TARGET_FILE"
        echo '+ (UnityFramework*)getInstance;' >> "$TARGET_FILE"
        echo '- (void)runEmbeddedWithArgc:(int)argc argv:(char*[])argv appLaunchOpts:(NSDictionary*)appLaunchOpts;' >> "$TARGET_FILE"
        echo '@end' >> "$TARGET_FILE"
    fi

    # module.modulemap を復元してから強制修正
    TARGET_FILE="ios/Frameworks/UnityFramework.framework/Modules/module.modulemap"
    if git show HEAD:ios/Frameworks/UnityFramework.framework/Modules/module.modulemap > "$TARGET_FILE" 2>/dev/null; then
        echo "module.modulemap: Restored from Git"
    else
        echo "module.modulemap: Not found in Git - creating basic version"
    fi

    # 強制修正: 正しいパス指定で上書き
    echo "Force updating module.modulemap with correct umbrella header path..."
    echo 'framework module UnityFramework {' > "$TARGET_FILE"
    echo '    umbrella header "UnityFramework.h"' >> "$TARGET_FILE"
    echo '    export *' >> "$TARGET_FILE"
    echo '    module * { export * }' >> "$TARGET_FILE"
    echo '    link "UnityFramework"' >> "$TARGET_FILE"
    echo '}' >> "$TARGET_FILE"

    # 重要: 重複ファイルの削除
    echo "Removing duplicate header files..."
    if [ -f "ios/Frameworks/UnityFramework.framework/UnityFramework.h" ]; then
        echo "Removing duplicate UnityFramework.h from root"
        rm -f "ios/Frameworks/UnityFramework.framework/UnityFramework.h"
    fi

    # Headers以外のUnityFramework.hファイルをすべて削除
    find ios/Frameworks/UnityFramework.framework -name "UnityFramework.h" -not -path "*/Headers/*" -delete 2>/dev/null || true

    # ファイル存在確認
    echo "Final verification of critical files:"
    for file in "UnityAppController.h" "LifeCycleListener.h" "RenderPluginDelegate.h" "UnityFramework.h"; do
        if [ -f "ios/Frameworks/UnityFramework.framework/Headers/$file" ]; then
            echo "$file: PRESENT"
        else
            echo "$file: MISSING"
            exit 1
        fi
    done

    if [ -f "ios/Frameworks/UnityFramework.framework/Modules/module.modulemap" ]; then
        echo "module.modulemap: PRESENT"
    else
        echo "module.modulemap: MISSING"
        exit 1
    fi

    # iOS ディレクトリに戻る
    cd ios

    # CocoaPods 用 podspec ファイル作成（静的ライブラリ統合版）
    echo "Creating optimized UnityFramework.podspec for CocoaPods..."
    PODSPEC_FILE="Frameworks/UnityFramework.framework/UnityFramework.podspec"
    echo 'Pod::Spec.new do |spec|' > "$PODSPEC_FILE"
    echo '  spec.name = "UnityFramework"' >> "$PODSPEC_FILE"
    echo '  spec.version = "2022.3.21"' >> "$PODSPEC_FILE"
    echo '  spec.summary = "Unity as Library Framework for iOS"' >> "$PODSPEC_FILE"
    echo '  spec.description = "Unity Framework for iOS with static libraries"' >> "$PODSPEC_FILE"
    echo '  spec.homepage = "https://unity.com"' >> "$PODSPEC_FILE"
    echo '  spec.license = { :type => "Unity" }' >> "$PODSPEC_FILE"
    echo '  spec.author = { "Unity" => "support@unity3d.com" }' >> "$PODSPEC_FILE"
    echo '  spec.source = { :path => "." }' >> "$PODSPEC_FILE"
    echo '  spec.ios.deployment_target = "15.0"' >> "$PODSPEC_FILE"
    echo '  spec.requires_arc = true' >> "$PODSPEC_FILE"
    echo '  spec.vendored_frameworks = "."' >> "$PODSPEC_FILE"
    echo '  spec.preserve_paths = "."' >> "$PODSPEC_FILE"
    echo '  spec.public_header_files = "Headers/**/*.h"' >> "$PODSPEC_FILE"
    echo '  spec.source_files = "Headers/**/*.h"' >> "$PODSPEC_FILE"
    echo '  spec.module_map = "Modules/module.modulemap"' >> "$PODSPEC_FILE"
    echo '' >> "$PODSPEC_FILE"
    echo '  # Static libraries' >> "$PODSPEC_FILE"
    echo '  spec.vendored_libraries = "../../../Libraries/libiPhone-lib.a", "../../../Libraries/baselib.a", "../../../Libraries/libUnityARKit.a"' >> "$PODSPEC_FILE"
    echo '' >> "$PODSPEC_FILE"
    echo '  # System frameworks (including missing AudioToolbox and AVFoundation)' >> "$PODSPEC_FILE"
    echo '  spec.frameworks = "AudioToolbox", "AVFoundation", "Metal", "CoreGraphics", "CoreImage", "ImageIO", "QuartzCore", "UIKit", "Foundation", "MetalKit", "CoreVideo", "Accelerate", "Security", "SystemConfiguration", "CoreText"' >> "$PODSPEC_FILE"
    echo '  spec.libraries = "c++", "z"' >> "$PODSPEC_FILE"
    echo '  spec.weak_frameworks = "ARKit", "CoreML", "GameController"' >> "$PODSPEC_FILE"
    echo '' >> "$PODSPEC_FILE"
    echo '  # Build settings' >> "$PODSPEC_FILE"
    echo '  spec.pod_target_xcconfig = {' >> "$PODSPEC_FILE"
    echo '    "FRAMEWORK_SEARCH_PATHS" => "$(inherited) $(PODS_TARGET_SRCROOT)",' >> "$PODSPEC_FILE"
    echo '    "LIBRARY_SEARCH_PATHS" => "$(inherited) $(PODS_TARGET_SRCROOT)/../../../Libraries",' >> "$PODSPEC_FILE"
    echo '    "OTHER_LDFLAGS" => "$(inherited) -framework UnityFramework -ObjC",' >> "$PODSPEC_FILE"
    echo '    "ENABLE_BITCODE" => "NO",' >> "$PODSPEC_FILE"
    echo '    "IPHONEOS_DEPLOYMENT_TARGET" => "15.0"' >> "$PODSPEC_FILE"
    echo '  }' >> "$PODSPEC_FILE"
    echo '' >> "$PODSPEC_FILE"
    echo '  spec.user_target_xcconfig = {' >> "$PODSPEC_FILE"
    echo '    "FRAMEWORK_SEARCH_PATHS" => "$(inherited) $(PODS_TARGET_SRCROOT)",' >> "$PODSPEC_FILE"
    echo '    "LIBRARY_SEARCH_PATHS" => "$(inherited) $(PODS_TARGET_SRCROOT)/../../../Libraries",' >> "$PODSPEC_FILE"
    echo '    "OTHER_LDFLAGS" => "$(inherited) -framework UnityFramework -ObjC",' >> "$PODSPEC_FILE"
    echo '    "ENABLE_BITCODE" => "NO"' >> "$PODSPEC_FILE"
    echo '  }' >> "$PODSPEC_FILE"
    echo 'end' >> "$PODSPEC_FILE"
    echo "Optimized UnityFramework.podspec with static libraries created"

    # Framework 構造の最適化
    if [ -d "Frameworks/UnityFramework.framework" ]; then
        echo "Unity Framework ready!"
        echo "Framework size: $(du -sh Frameworks/UnityFramework.framework)"

        # Framework permissions 修正
        echo "Setting framework permissions..."
        chmod -R 755 Frameworks/UnityFramework.framework/

        # Static Libraries permissions 修正
        echo "Setting static libraries permissions..."
        chmod 644 Libraries/*.a

        # Framework構造の最終確認
        echo "Framework structure verification:"
        if [ -f "Frameworks/UnityFramework.framework/UnityFramework" ]; then
            echo "- Binary: OK"
        else
            echo "- Binary: MISSING"
        fi

        HEADER_COUNT=$(ls Frameworks/UnityFramework.framework/Headers/ 2>/dev/null | wc -l)
        echo "- Headers count: $HEADER_COUNT files"

        if [ -f "Frameworks/UnityFramework.framework/Modules/module.modulemap" ]; then
            echo "- Module map: OK"
        else
            echo "- Module map: MISSING"
        fi

        # 重複確認
        DUPLICATE_COUNT=$(find Frameworks/UnityFramework.framework -name "UnityFramework.h" 2>/dev/null | wc -l)
        echo "- UnityFramework.h count: $DUPLICATE_COUNT (should be 1)"

        # 静的ライブラリ確認
        LIBRARY_COUNT=$(ls Libraries/*.a 2>/dev/null | wc -l)
        echo "- Static libraries count: $LIBRARY_COUNT files"

    else
        echo "Unity Framework not in correct location!"
        exit 1
    fi

    # プロジェクトルートに戻る
    cd ..

    echo "Pre-build script completed - Unity Framework & Static Libraries ready for CocoaPods!"
    echo "Framework conflicts resolved, duplicate files removed!"
    echo "Static libraries extracted and configured!"

else
    echo "UnityFramework.zip not found!"
    exit 1
fi

echo "Script execution completed successfully"