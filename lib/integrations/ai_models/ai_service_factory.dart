import 'ai_service_interface.dart';
import 'openai_service.dart';
import 'anthropic_service.dart';
import 'google_service.dart';
import 'ollama_service.dart';
import 'azure_service.dart';
import 'ai_model_manager.dart';

/// AI服务工厂
class AIServiceFactory {
  /// 根据提供商创建相应的AI服务实例
  static AIServiceInterface createService(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return OpenAIService();
      case 'anthropic':
        return AnthropicService();
      case 'google':
        return GoogleService();
      case 'ollama':
        return OllamaService();
      case 'azure':
        return AzureService();
      default:
        throw Exception('Unsupported AI provider: $provider');
    }
  }
  
  /// 发送消息到指定的AI模型
  static Future<String> sendMessage(
    String message,
    List<Map<String, String>> history,
    AIModelConfig modelConfig,
  ) async {
    final service = createService(modelConfig.provider);
    return await service.sendMessage(message, history, modelConfig);
  }
  
  /// 验证模型配置
  static Future<bool> validateConfig(AIModelConfig modelConfig) async {
    try {
      final service = createService(modelConfig.provider);
      return await service.validateConfig(modelConfig);
    } catch (e) {
      return false;
    }
  }
  
  /// 获取模型支持的功能列表
  static List<String> getSupportedFeatures(AIModelConfig modelConfig) {
    try {
      final service = createService(modelConfig.provider);
      return service.getSupportedFeatures(modelConfig);
    } catch (e) {
      return [];
    }
  }
}