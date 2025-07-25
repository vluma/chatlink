import 'package:flutter/foundation.dart';
  import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// AI模型配置
class AIModelConfig {
  final String id;
  final String name;
  final String provider;
  final String apiKey;
  final String baseUrl;
  final Map<String, dynamic> additionalParams;

  AIModelConfig({
    required this.id,
    required this.name,
    required this.provider,
    required this.apiKey,
    required this.baseUrl,
    this.additionalParams = const {},
  });

  /// 从JSON创建配置
  factory AIModelConfig.fromJson(Map<String, dynamic> json) {
    return AIModelConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      apiKey: json['apiKey'] as String,
      baseUrl: json['baseUrl'] as String,
      additionalParams: Map<String, dynamic>.from(json['additionalParams'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'additionalParams': additionalParams,
    };
  }

  /// 创建副本
  AIModelConfig copyWith({
    String? id,
    String? name,
    String? provider,
    String? apiKey,
    String? baseUrl,
    Map<String, dynamic>? additionalParams,
  }) {
    return AIModelConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      additionalParams: additionalParams ?? this.additionalParams,
    );
  }
}

/// AI模型集成管理器
class AIModelManager with ChangeNotifier {
  // 单例实例
  static final AIModelManager _instance = AIModelManager._internal();
  factory AIModelManager() => _instance;
  AIModelManager._internal();

  // SharedPreferences实例
  SharedPreferences? _prefs;

  // 配置的模型列表
  final List<AIModelConfig> _configuredModels = [];
  
  // 当前选中的模型
  AIModelConfig? _currentModel;
  
  // 获取配置的模型列表
  List<AIModelConfig> get configuredModels => List.unmodifiable(_configuredModels);

  // 获取当前模型
  AIModelConfig? get currentModel => _currentModel;

  /// 初始化模型管理器
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadModels();
  }

  /// 从持久化存储中加载模型
  Future<void> _loadModels() async {
    final jsonString = _prefs?.getString('ai_configured_models');
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _configuredModels.clear();
        _configuredModels.addAll(
          jsonList.map((json) => AIModelConfig.fromJson(json.cast<String, dynamic>())).toList(),
        );
        notifyListeners();
      } catch (e) {
        // 解析错误时，清除存储的数据
        _prefs?.remove('ai_configured_models');
      }
    }
  }

  /// 保存模型到持久化存储
  Future<void> _saveModels() async {
    final modelsJson = _configuredModels.map((model) => model.toJson()).toList();
    final jsonString = jsonEncode(modelsJson);
    await _prefs?.setString('ai_configured_models', jsonString);
  }

  /// 添加模型配置
  void addModel(AIModelConfig model) {
    // 检查是否已存在相同ID的模型
    final existingIndex = _configuredModels.indexWhere((m) => m.id == model.id);
    if (existingIndex >= 0) {
      // 更新现有模型
      _configuredModels[existingIndex] = model;
    } else {
      // 检查是否已存在相同提供商和名称的模型
      final nameIndex = _configuredModels.indexWhere(
        (m) => m.provider == model.provider && m.name == model.name
      );
      
      if (nameIndex >= 0) {
        // 更新现有模型
        _configuredModels[nameIndex] = model;
      } else {
        // 添加新模型
        _configuredModels.add(model);
      }
    }
    
    // 保存到持久化存储
    _saveModels();
    notifyListeners();
  }

  /// 移除模型配置
  void removeModel(String modelId) {
    _configuredModels.removeWhere((model) => model.id == modelId);
    if (_currentModel?.id == modelId) {
      _currentModel = null;
      notifyListeners();
    }
    
    // 保存到持久化存储
    _saveModels();
  }

  /// 设置当前模型
  void setCurrentModel(String modelId) {
    try {
      _currentModel = _configuredModels.firstWhere((model) => model.id == modelId);
    } catch (e) {
      _currentModel = null;
    }
    notifyListeners();
  }

  /// 根据提供商获取模型列表
  List<AIModelConfig> getModelsByProvider(String provider) {
    return _configuredModels.where((model) => model.provider == provider).toList();
  }

  /// 获取支持的提供商列表
  List<String> getSupportedProviders() {
    final providers = <String>{};
    for (final model in _configuredModels) {
      providers.add(model.provider);
    }
    return providers.toList();
  }
}