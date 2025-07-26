import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // AI设置
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('AI设置'),
            subtitle: const Text('配置AI服务商和模型'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push('/settings/ai');
            },
          ),
          const Divider(),
          
          // 账户设置
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('账户'),
            subtitle: const Text('管理您的账户信息'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: 实现账户设置功能
            },
          ),
          const Divider(),
          
          // 通知设置
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知'),
            subtitle: const Text('配置通知偏好'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: 实现通知设置功能
            },
          ),
          const Divider(),
          
          // 隐私设置
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('隐私'),
            subtitle: const Text('管理隐私设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: 实现隐私设置功能
            },
          ),
          const Divider(),
          
          // 关于
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            subtitle: const Text('应用信息和版本'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: 实现关于页面功能
            },
          ),
        ],
      ),
    );
  }
}