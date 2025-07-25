import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ai_service_interface.dart';
import 'ai_model_manager.dart';

/// Azure服务实现
class AzureService implements AIServiceInterface {
  @override
  Future<String> sendMessage(
    String message,
    List<Map<String, String>> history,
    AIModelConfig modelConfig,
  ) async {
    try {
      // Azure OpenAI API URL格式
      // 通常为: https://<resource-name>.openai.azure.com/openai/deployments/<deployment-name>/chat/completions?api-version=<api-version>
      final url = Uri.parse(modelConfig.baseUrl);
      
      // 构建消息历史
      final messages = [
        ...history,
        {'role': 'user', 'content': message}
      ];
      
      final body = {
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
          'api-key': modelConfig.apiKey,
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(response.body);
        throw AIServiceException(
          'Azure OpenAI API error: ${errorData['error']?['message'] ?? 'Unknown error'}'
        );
      }
    } catch (e) {
      if (e is AIServiceException) {
        rethrow;
      }
      throw AIServiceException('Failed to connect to Azure OpenAI: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> validateConfig(AIModelConfig modelConfig) async {
    try {
      // Azure没有简单的验证端点，我们可以尝试调用模型列表API（如果配置了的话）
      // 或者直接返回true，因为我们假设配置是正确的
      return modelConfig.baseUrl.isNotEmpty && modelConfig.apiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  @override
  List<String> getSupportedFeatures(AIModelConfig modelConfig) {
    // Azure OpenAI支持与OpenAI相同的功能
    return ['text-generation', 'code-generation'];
  }
}