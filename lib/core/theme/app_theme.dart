import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// 应用主题配置
class AppTheme {
  /// 获取移动端主题
  static ThemeData get mobileTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
    );
  }

  /// 获取桌面端主题
  static ThemeData get desktopTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
    );
  }

  /// 获取TV端主题
  static ThemeData get tvTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
    );
  }

  /// 获取VR端主题
  static ThemeData get vrTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
    );
  }

  /// 获取macOS风格主题
  static ThemeData get macOS_theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFE5E5E5),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        barBackgroundColor: Color(0xFFE5E5E5),
        textTheme: CupertinoTextThemeData(
          navTitleTextStyle: TextStyle(
            fontFamily: '.SF NS Text', // macOS系统字体
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontFamily: '.SF NS Display', // macOS系统字体
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE5E5E5),
        foregroundColor: Colors.black,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: '.SF NS Text', // macOS系统字体
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        toolbarHeight: 44,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontFamily: '.SF NS Text'),
        bodyLarge: TextStyle(fontFamily: '.SF NS Text'),
        titleLarge: TextStyle(
          fontFamily: '.SF NS Display',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: '.SF NS Text',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
    );
  }
}