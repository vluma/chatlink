import 'dart:convert';
import 'dart:math';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_session.dart';

class SessionRepository {
  // SharedPreferences实例
  SharedPreferences? _prefs;
  
  // 用于存储会话的键名
  static const String _sessionsKey = 'chat_sessions';
  static const String _activeSessionKey = 'active_session_id';

  // 内存中的会话列表
  final List<ChatSession> _sessions = [];
  
  // 当前活动会话
  ChatSession? _activeSession;

  /// 初始化仓库，从持久化存储中加载数据
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSessions();
    await _loadActiveSession();
  }

  /// 从持久化存储中加载会话
  Future<void> _loadSessions() async {
    final sessionsJson = _prefs?.getString(_sessionsKey);
    if (sessionsJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(sessionsJson);
        _sessions.clear();
        _sessions.addAll(
          jsonList.map((json) => ChatSession.fromJson(json as Map<String, dynamic>)).toList(),
        );
      } catch (e) {
        // 如果解析失败，清除存储的数据
        _prefs?.remove(_sessionsKey);
      }
    }
  }

  /// 从持久化存储中加载活动会话
  Future<void> _loadActiveSession() async {
    final activeSessionId = _prefs?.getString(_activeSessionKey);
    if (activeSessionId != null) {
      _activeSession = _sessions.firstWhereOrNull((session) => session.id == activeSessionId);
    }
  }

  /// 创建新会话
  ChatSession createSession({String? title, String? systemPrompt}) {
    final now = DateTime.now();
    final session = ChatSession(
      id: _generateId(),
      title: title ?? '新会话',
      createdAt: now,
      updatedAt: now,
      systemPrompt: systemPrompt,
    );
    
    _sessions.add(session);
    _activeSession = session;
    
    // 保存到持久化存储
    _saveSessions();
    _prefs?.setString(_activeSessionKey, session.id);
    
    return session;
  }

  /// 获取所有会话
  List<ChatSession> getAllSessions() {
    // 按更新时间倒序排列
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(_sessions);
  }

  /// 根据ID获取会话
  ChatSession? getSessionById(String id) {
    return _sessions.firstWhereOrNull((session) => session.id == id);
  }

  /// 删除会话
  void deleteSession(String id) {
    _sessions.removeWhere((session) => session.id == id);
    if (_activeSession?.id == id) {
      _activeSession = null;
      _prefs?.remove(_activeSessionKey);
    }
    
    // 保存更改到持久化存储
    _saveSessions();
  }

  /// 更新会话标题
  void updateSessionTitle(String sessionId, String newTitle) {
    final session = getSessionById(sessionId);
    if (session != null) {
      final index = _sessions.indexOf(session);
      _sessions[index] = session.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );
      
      // 保存更改到持久化存储
      _saveSessions();
    }
  }

  /// 更新会话
  ChatSession updateSession(ChatSession updatedSession) {
    final session = getSessionById(updatedSession.id);
    if (session != null) {
      final index = _sessions.indexOf(session);
      _sessions[index] = updatedSession;
      if (_activeSession?.id == updatedSession.id) {
        _activeSession = updatedSession;
      }
      
      // 保存更改到持久化存储
      _saveSessions();
      
      return updatedSession;
    }
    throw Exception('Session not found: ${updatedSession.id}');
  }

  /// 添加消息到会话
  void addMessageToSession(String sessionId, types.Message message) {
    final session = getSessionById(sessionId);
    if (session != null) {
      final index = _sessions.indexOf(session);
      final updatedMessages = List<types.Message>.from(session.messages)
        ..insert(0, message);
      
      _sessions[index] = session.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );
      
      // 保存更改到持久化存储
      _saveSessions();
    }
  }

  /// 设置当前活动会话
  void setActiveSession(ChatSession session) {
    _activeSession = session;
    _prefs?.setString(_activeSessionKey, session.id);
  }

  /// 获取当前活动会话
  ChatSession? getActiveSession() {
    return _activeSession;
  }

  /// 将会话保存到持久化存储
  Future<void> _saveSessions() async {
    final jsonList = _sessions.map((session) => session.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs?.setString(_sessionsKey, jsonString);
  }

  /// 生成唯一ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
}

/// 扩展方法：查找第一个匹配元素或返回null
extension FirstWhereOrNullExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}