import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ai_service_interface.dart';
import 'ai_model_manager.dart';

/// Ollama服务实现
class OllamaService implements AIServiceInterface {
  @override
  Future<String> sendMessage(
    String message,
    List<Map<String, String>> history,
    AIModelConfig modelConfig,
  ) async {
    try {
      final url = Uri.parse('${modelConfig.baseUrl}/api/chat');
      
      // 构建消息历史
      final messages = [
        ...history.map((m) => {
              'role': m['role'] == 'assistant' ? 'assistant' : 'user',
              'content': m['content'] ?? '',
            }),
        {'role': 'user', 'content': message}
      ];
      
      final body = <String, dynamic>{
        'model': modelConfig.name,
        'messages': messages,
        'stream': false,
      };
      
      // 添加额外参数（如果有的话）
      modelConfig.additionalParams.forEach((key, value) {
        body[key] = value;
      });
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 检查响应格式
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message']['content'];
        } else {
          // 如果响应格式不符合预期，直接返回整个响应内容
          return response.body;
        }
      } else {
        // 尝试解析错误信息
        try {
          final errorData = jsonDecode(response.body);
          throw AIServiceException(
            'Ollama API error: ${errorData['error'] ?? 'Unknown error (status: ${response.statusCode})'}'
          );
        } catch (e) {
          // 如果无法解析JSON，直接返回状态码
          throw AIServiceException(
            'Ollama API error: HTTP ${response.statusCode} - ${response.body}'
          );
        }
      }
    } catch (e) {
      if (e is AIServiceException) {
        rethrow;
      }
      throw AIServiceException('Failed to connect to Ollama: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> validateConfig(AIModelConfig modelConfig) async {
    try {
      // 尝试获取模型列表来验证连接
      final url = Uri.parse('${modelConfig.baseUrl}/api/tags');
      final response = await http.get(url);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  @override
  List<String> getSupportedFeatures(AIModelConfig modelConfig) {
    // Ollama支持多种模型，包括文本生成、代码生成等
    return ['text-generation', 'code-generation'];
  }
  
  /// 获取本地可用的模型列表
  Future<List<String>> getLocalModels(String baseUrl) async {
    try {
      final url = Uri.parse('$baseUrl/api/tags');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = <String>[];
        if (data is Map<String, dynamic> && data.containsKey('models')) {
          for (final model in data['models']) {
            if (model is Map<String, dynamic> && model.containsKey('name')) {
              // 处理模型名称，移除标签部分（如:latest）
              final fullName = model['name'].toString();
              final name = fullName.split(':').first;
              models.add(name);
            }
          }
        }
        return models;
      } else {
        throw AIServiceException('Failed to get Ollama models: ${response.statusCode}');
      }
    } catch (e) {
      throw AIServiceException('Failed to connect to Ollama: ${e.toString()}');
    }
  }
}