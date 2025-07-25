import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:json_annotation/json_annotation.dart';

part 'chat_session.g.dart';

@JsonSerializable()
class ChatSession {
  /// 会话唯一标识符
  final String id;

  /// 会话标题
  final String title;

  /// 会话创建时间
  final DateTime createdAt;

  /// 会话最后更新时间
  final DateTime updatedAt;

  /// 消息列表
  @JsonKey(toJson: _messagesToJson, fromJson: _messagesFromJson)
  final List<types.Message> messages;

  /// AI模型设置
  final String model;

  /// 系统提示词
  final String? systemPrompt;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    List<types.Message>? messages,
    this.model = 'gpt-3.5-turbo',
    this.systemPrompt,
  }) : messages = messages ?? [];

  /// 创建副本（用于更新）
  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<types.Message>? messages,
    String? model,
    String? systemPrompt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) => _$ChatSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionToJson(this);

  static String _messagesToJson(List<types.Message> messages) {
    final List<Map<String, dynamic>> jsonList = messages.map((message) {
      return message.toJson();
    }).toList();
    return jsonEncode(jsonList);
  }

  static List<types.Message> _messagesFromJson(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) {
      return types.Message.fromJson(json as Map<String, dynamic>);
    }).toList();
  }
}