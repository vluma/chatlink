import 'ai_model_manager.dart';

/// 示例配置文件
class SampleConfigurations {
  /// 获取OpenAI示例配置
  static AIModelConfig get openAIConfig => AIModelConfig(
        id: 'openai-gpt4',
        name: 'gpt-4',
        provider: 'openai',
        apiKey: 'your-openai-api-key',
        baseUrl: 'https://api.openai.com/v1',
        additionalParams: {
          'temperature': 0.7,
          'max_tokens': 2048,
        },
      );
  
  /// 获取Anthropic示例配置
  static AIModelConfig get anthropicConfig => AIModelConfig(
        id: 'anthropic-claude3',
        name: 'claude-3-sonnet-20240229',
        provider: 'anthropic',
        apiKey: 'your-anthropic-api-key',
        baseUrl: 'https://api.anthropic.com/v1',
        additionalParams: {
          'max_tokens': 1024,
        },
      );
  
  /// 获取Google示例配置
  static AIModelConfig get googleConfig => AIModelConfig(
        id: 'google-gemini',
        name: 'gemini-pro',
        provider: 'google',
        apiKey: 'your-google-api-key',
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
        additionalParams: {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
        },
      );
  
  /// 获取Azure示例配置
  static AIModelConfig get azureConfig => AIModelConfig(
        id: 'azure-gpt4',
        name: 'gpt-4',
        provider: 'azure',
        apiKey: 'your-azure-api-key',
        baseUrl: 'https://your-resource-name.openai.azure.com/openai/deployments/gpt-4/chat/completions?api-version=2024-02-15-preview',
        additionalParams: {
          'temperature': 0.7,
          'max_tokens': 2048,
        },
      );
  
  /// 获取Ollama示例配置
  static AIModelConfig get ollamaConfig => AIModelConfig(
        id: 'ollama-llama3',
        name: 'llama3',
        provider: 'ollama',
        apiKey: '', // Ollama通常不需要API密钥
        baseUrl: 'http://localhost:11434', // Ollama默认运行地址
        additionalParams: {
          'temperature': 0.7,
        },
      );
  
  /// 获取所有示例配置
  static List<AIModelConfig> getAllSampleConfigs() => [
        openAIConfig,
        anthropicConfig,
        googleConfig,
        azureConfig,
        ollamaConfig,
      ];
}