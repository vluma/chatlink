import 'package:flutter/material.dart';

import '../../ai_chat/ui/ai_chat_screen.dart';
import '../../knowledge_base/ui/knowledge_base_screen.dart';
import '../../settings/ui/settings_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AiChatScreen(),
    const KnowledgeBaseScreen(),
    const DiscoveryScreenContent(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧导航栏
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('会话'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: Text('知识库'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: Text('发现'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('设置'),
              ),
            ],
          ),
          // 主内容区域
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
    );
  }
}

class DiscoveryScreenContent extends StatelessWidget {
  const DiscoveryScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('发现页面'),
    );
  }
}