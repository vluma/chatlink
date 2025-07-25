import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ai_service_interface.dart';
import 'ai_model_manager.dart';

/// Google服务实现
class GoogleService implements AIServiceInterface {
  @override
  Future<String> sendMessage(
    String message,
    List<Map<String, String>> history,
    AIModelConfig modelConfig,
  ) async {
    try {
      // Google Gemini API URL格式
      final url = Uri.parse(
        '${modelConfig.baseUrl}/models/${modelConfig.name}:generateContent?key=${modelConfig.apiKey}'
      );
      
      // 构建内容
      final contents = [
        ...history.map((m) => ({
              'role': m['role'] == 'assistant' ? 'model' : 'user',
              'parts': [
                {'text': m['content'] ?? ''}
              ]
            })),
        {
          'role': 'user',
          'parts': [
            {'text': message}
          ]
        }
      ];
      
      final body = <String, dynamic>{
        'contents': contents,
      };
      
      // 添加生成配置（如果有的话）
      if (modelConfig.additionalParams.isNotEmpty) {
        final generationConfig = <String, dynamic>{};
        if (modelConfig.additionalParams.containsKey('temperature')) {
          generationConfig['temperature'] = modelConfig.additionalParams['temperature'];
        }
        if (modelConfig.additionalParams.containsKey('maxOutputTokens')) {
          generationConfig['maxOutputTokens'] = modelConfig.additionalParams['maxOutputTokens'];
        }
        body['generationConfig'] = generationConfig;
      }
      
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
        throw AIServiceException(
          'Google API error: ${errorData['error']?['message'] ?? 'Unknown error'}'
        );
      }
    } catch (e) {
      if (e is AIServiceException) {
        rethrow;
      }
      throw AIServiceException('Failed to connect to Google: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> validateConfig(AIModelConfig modelConfig) async {
    try {
      // 尝试列出模型来验证API密钥
      final url = Uri.parse('${modelConfig.baseUrl}/models?key=${modelConfig.apiKey}');
      final response = await http.get(url);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  @override
  List<String> getSupportedFeatures(AIModelConfig modelConfig) {
    // Google Gemini支持文本生成、多模态等
    return ['text-generation', 'multimodal'];
  }
}