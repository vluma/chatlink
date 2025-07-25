import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ai_service_interface.dart';
import 'ai_model_manager.dart';

/// Anthropic服务实现
class AnthropicService implements AIServiceInterface {
  @override
  Future<String> sendMessage(
    String message,
    List<Map<String, String>> history,
    AIModelConfig modelConfig,
  ) async {
    try {
      final url = Uri.parse('${modelConfig.baseUrl}/messages');
      
      // 构建消息历史
      final messages = [
        ...history.map((m) => ({
              'role': m['role'] == 'assistant' ? 'assistant' : 'user',
              'content': m['content'] ?? '',
            })),
        {'role': 'user', 'content': message}
      ];
      
      final body = {
        'model': modelConfig.name,
        'messages': messages,
        'max_tokens': modelConfig.additionalParams['max_tokens'] ?? 1024,
      };
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': modelConfig.apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'];
      } else {
        final errorData = jsonDecode(response.body);
        throw AIServiceException(
          'Anthropic API error: ${errorData['error']?['message'] ?? 'Unknown error'}'
        );
      }
    } catch (e) {
      if (e is AIServiceException) {
        rethrow;
      }
      throw AIServiceException('Failed to connect to Anthropic: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> validateConfig(AIModelConfig modelConfig) async {
    // Anthropic没有简单的模型列表API，我们尝试调用一个简单的API来验证
    try {
      final url = Uri.parse('${modelConfig.baseUrl}/models');
      final response = await http.get(
        url,
        headers: {
          'X-API-Key': modelConfig.apiKey,
          'anthropic-version': '2023-06-01',
        },
      );
      
      // 如果返回404，说明这个API不存在，但API密钥可能是有效的
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      return false;
    }
  }
  
  @override
  List<String> getSupportedFeatures(AIModelConfig modelConfig) {
    // Anthropic Claude主要支持对话和文本生成
    return ['text-generation', 'conversational-ai'];
  }
}