import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../integrations/ai_models/ai_model_manager.dart';

/// AI异常类
class AIException implements Exception {
  final String message;
  
  AIException(this.message);
  
  @override
  String toString() => 'AIException: $message';
}

/// AI服务类，用于处理不同提供商的AI模型调用
class AIService {
  /// 发送消息到AI模型并获取回复
  static Future<String> sendMessage(
    String message,
    List<Map<String, String>> history,
    AIModelConfig model,
  ) async {
    try {
      switch (model.provider) {
        case 'openai':
          return await _sendOpenAIRequest(message, history, model);
        case 'anthropic':
          return await _sendAnthropicRequest(message, history, model);
        case 'google':
          return await _sendGoogleRequest(message, history, model);
        case 'azure':
          return await _sendAzureRequest(message, history, model);
        case 'ollama':
          return await _sendOllamaRequest(message, history, model);
        default:
          throw Exception('Unsupported AI provider: ${model.provider}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to send message to AI: ${e.toString()}');
    }
  }

  /// 发送请求到OpenAI
  static Future<String> _sendOpenAIRequest(
    String message,
    List<Map<String, String>> history,
    AIModelConfig model,
  ) async {
    final url = Uri.parse('${model.baseUrl.isEmpty ? 'https://api.openai.com' : model.baseUrl}/v1/chat/completions');
    
    // 处理历史消息，确保角色正确
    final messages = [
      ...history.map((m) => {
            'role': m['role'] == 'assistant' ? 'assistant' : 
                   m['role'] == 'system' ? 'system' : 'user',
            'content': m['content'] ?? ''
          }),
      {'role': 'user', 'content': message}
    ];

    final body = {
      'model': model.name,
      'messages': messages,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${model.apiKey}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('OpenAI API error: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to connect to OpenAI: ${e.toString()}');
    }
  }

  /// 发送请求到Anthropic
  static Future<String> _sendAnthropicRequest(
    String message,
    List<Map<String, String>> history,
    AIModelConfig model,
  ) async {
    final url = Uri.parse('https://api.anthropic.com/v1/messages');
    
    final messages = [
      ...history.map((m) => {
            'role': m['role'] == 'assistant' ? 'assistant' : 'user',
            'content': m['content']!,
          }),
      {'role': 'user', 'content': message}
    ];

    final body = {
      'model': model.name,
      'messages': messages,
      'max_tokens': 1024,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': model.apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'];
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('Anthropic API error: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to connect to Anthropic: ${e.toString()}');
    }
  }

  /// 发送请求到Google
  static Future<String> _sendGoogleRequest(
    String message,
    List<Map<String, String>> history,
    AIModelConfig model,
  ) async {
    final apiKey = model.apiKey;
    final url = Uri.parse('${model.baseUrl.isEmpty ? 'https://generativelanguage.googleapis.com' : model.baseUrl}/models/${model.name}:generateContent?key=$apiKey');
    
    final contents = [
      ...history.map((m) => {
            'role': m['role'] == 'assistant' ? 'model' : 'user',
            'parts': [
              {'text': m['content']}
            ]
          }),
      {
        'role': 'user',
        'parts': [
          {'text': message}
        ]
      }
    ];

    final body = {
      'contents': contents,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('Google API error: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to connect to Google: ${e.toString()}');
    }
  }

  /// 发送请求到Azure
  static Future<String> _sendAzureRequest(
    String message,
    List<Map<String, String>> history,
    AIModelConfig model,
  ) async {
    final url = Uri.parse('${model.baseUrl}/chat/completions?api-version=2023-05-15');
    
    final messages = [
      ...history.map((m) => {
            'role': m['role'] == 'assistant' ? 'assistant' : 'user',
            'content': m['content'] ?? '',
          }),
      {'role': 'user', 'content': message}
    ];

    final body = {
      'model': model.name,
      'messages': messages,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'api-key': model.apiKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('Azure API error: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to connect to Azure: ${e.toString()}');
    }
  }

  /// 发送请求到Ollama
  static Future<String> _sendOllamaRequest(
    String message,
    List<Map<String, String>> history,
    AIModelConfig model,
  ) async {
    final url = Uri.parse('${model.baseUrl.isEmpty ? 'http://localhost:11434' : model.baseUrl}/api/chat');
    
    final messages = [
      ...history,
      {'role': 'user', 'content': message}
    ];
    
    // 构建Ollama格式的messages
    final ollamaMessages = messages.map((msg) {
      return {
        'role': msg['role'],
        'content': msg['content'],
      };
    }).toList();

    final body = {
      'model': model.name,
      'messages': ollamaMessages,
      'stream': false,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message']['content'];
      } else {
        throw AIException('Ollama API error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to connect to Ollama: ${e.toString()}');
    }
  }
}