import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 平台检测工具类
class PlatformUtils {
  /// 是否为移动端 (Android 或 iOS)
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// 是否为桌面端 (Windows, macOS, Linux)
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// 是否为Web端
  static bool get isWeb => kIsWeb;

  /// 是否为TV端 (目前通过Android平台简单判断)
  static bool get isTV {
    // 这里只是一个简单的判断，实际TV应用可能需要更复杂的检测逻辑
    if (kIsWeb) return false;
    // TV通常运行在Android平台上，但有特殊的屏幕尺寸和交互方式
    return Platform.isAndroid;
  }

  /// 是否为VR端 (目前VR支持有限，暂时返回false)
  static bool get isVR {
    // 当前Flutter对VR的支持有限，暂时返回false
    return false;
  }
}