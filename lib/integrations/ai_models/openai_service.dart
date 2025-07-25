import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ai_service_interface.dart';
import 'ai_model_manager.dart';

/// OpenAI服务实现
class OpenAIService implements AIServiceInterface {
  @override
  Future<String> sendMessage(
    String message,
    List<Map<String, String>> history,
    AIModelConfig modelConfig,
  ) async {
    try {
      final url = Uri.parse('${modelConfig.baseUrl}/chat/completions');
      
      // 构建消息历史
      final messages = [
        ...history,
        {'role': 'user', 'content': message}
      ];
      
      final body = {
        'model': modelConfig.name,
        'messages': messages,
      };
      
      // 添加额外参数（如果有的话）
      if (modelConfig.additionalParams.containsKey('temperature')) {
        body['temperature'] = modelConfig.additionalParams['temperature'];
      }
      
      if (modelConfig.additionalParams.containsKey('max_tokens')) {
        body['max_tokens'] = modelConfig.additionalParams['max_tokens'];
      }
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${modelConfig.apiKey}',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(response.body);
        throw AIServiceException(
          'OpenAI API error: ${errorData['error']?['message'] ?? 'Unknown error'}'
        );
      }
    } catch (e) {
      if (e is AIServiceException) {
        rethrow;
      }
      throw AIServiceException('Failed to connect to OpenAI: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> validateConfig(AIModelConfig modelConfig) async {
    try {
      final url = Uri.parse('${modelConfig.baseUrl}/models');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${modelConfig.apiKey}',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  @override
  List<String> getSupportedFeatures(AIModelConfig modelConfig) {
    // OpenAI通常支持文本生成、代码生成等
    return ['text-generation', 'code-generation'];
  }
}