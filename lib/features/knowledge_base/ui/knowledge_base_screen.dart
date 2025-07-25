import 'package:flutter/material.dart';

/// 知识库屏幕
class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识库'),
      ),
      body: const Center(
        child: Text('知识库功能'),
      ),
    );
  }
}