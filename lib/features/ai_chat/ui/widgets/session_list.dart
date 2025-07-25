import 'package:flutter/material.dart';

import '../../data/models/chat_session.dart';
import '../../data/repositories/session_repository.dart';

class SessionList extends StatelessWidget {
  final SessionRepository sessionRepository;
  final VoidCallback onCreateNewSession;
  final Function(ChatSession) onSessionSelected;

  const SessionList({
    super.key,
    required this.sessionRepository,
    required this.onCreateNewSession,
    required this.onSessionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sessions = sessionRepository.getAllSessions();

    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // 顶部工具栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '会话历史',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onCreateNewSession,
                  tooltip: '新建会话',
                ),
              ],
            ),
          ),
          
          // 会话列表
          Expanded(
            child: sessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      return _buildSessionItem(
                        context,
                        sessions[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态视图
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无会话',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '点击右上角创建新会话',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建会话项
  Widget _buildSessionItem(BuildContext context, ChatSession session) {
    return ListTile(
      title: Text(
        session.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDateTime(session.updatedAt),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          Text(
            session.model,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      onTap: () => onSessionSelected(session),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        onPressed: () {
          _showDeleteConfirmation(context, session);
        },
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.month}-${dateTime.day}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmation(BuildContext context, ChatSession session) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除会话"${session.title}"吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                sessionRepository.deleteSession(session.id);
                Navigator.of(context).pop();
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}