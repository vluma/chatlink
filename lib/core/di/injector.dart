import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';

/// 依赖注入配置类
class Injector {
  static final Injector _instance = Injector._internal();
  factory Injector() => _instance;
  
  late final GoRouter router;

  Injector._internal() {
    router = appRouter;
  }
}

/// 主页屏幕占位符
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('主页'),
      ),
    );
  }
}

/// AI聊天屏幕占位符
class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('AI聊天'),
      ),
    );
  }
}

/// 知识库屏幕占位符
class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('知识库'),
      ),
    );
  }
}

/// 发现屏幕占位符
class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('发现'),
      ),
    );
  }
}

/// 设置屏幕占位符
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('设置'),
      ),
    );
  }
}