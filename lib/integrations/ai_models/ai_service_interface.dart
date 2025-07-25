import '../ai_models/ai_model_manager.dart';

/// AI服务异常
class AIServiceException implements Exception {
  final String message;
  
  AIServiceException(this.message);
  
  @override
  String toString() => 'AIServiceException: $message';
}

/// AI服务接口
abstract class AIServiceInterface {
  /// 发送消息到AI模型
  Future<String> sendMessage(
    String message,
    List<Map<String, String>> history,
    AIModelConfig modelConfig,
  );
  
  /// 检查模型配置是否有效
  Future<bool> validateConfig(AIModelConfig modelConfig);
  
  /// 获取模型支持的功能列表
  List<String> getSupportedFeatures(AIModelConfig modelConfig);
}