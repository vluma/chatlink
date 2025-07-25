  import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../integrations/ai_models/ai_model_manager.dart';
import '../../../integrations/ai_models/ai_service_factory.dart';
import '../../../integrations/ai_models/ollama_service.dart';
import 'ai_model_list_screen.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../ai_chat/data/repositories/session_repository.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  // 当前选中的AI服务商
  String _selectedProvider = 'openai';
  
  // 当前选中的模型
  String _selectedModel = 'gpt-3.5-turbo';
  
  // API密钥
  final TextEditingController _apiKeyController = TextEditingController();
  
  // Ollama服务器地址
  final TextEditingController _ollamaServerController = TextEditingController();
  
  // Ollama模型名称（用于手动输入）
  final TextEditingController _ollamaModelController = TextEditingController();
  
  // Ollama本地模型列表
  List<String> _ollamaLocalModels = [];
  
  // 是否正在检测模型
  bool _isDetectingModels = false;
  
  // 各个服务商支持的模型列表
  final Map<String, List<String>> _providerModels = {
    'openai': [
      'gpt-3.5-turbo',
      'gpt-3.5-turbo-16k',
      'gpt-4',
      'gpt-4-32k',
      'gpt-4-turbo',
      'gpt-4o',
    ],
    'anthropic': [
      'claude-3-haiku',
      'claude-3-sonnet',
      'claude-3-opus',
    ],
    'google': [
      'gemini-pro',
      'gemini-pro-vision',
    ],
    'azure': [
      'gpt-35-turbo',
      'gpt-4',
      'gpt-4-32k',
    ],
    'ollama': [
      'llama2',
      'llama3',
      'mistral',
      'mixtral',
      'codellama',
      'phi3',
    ],
  };
  
  // 服务商显示名称
  final Map<String, String> _providerNames = {
    'openai': 'OpenAI',
    'anthropic': 'Anthropic',
    'google': 'Google',
    'azure': 'Azure OpenAI',
    'ollama': 'Ollama (本地)',
  };

  // 模型管理器实例
  final AIModelManager _aiModelManager = AIModelManager();
  
  // UUID实例
  final Uuid _uuid = Uuid();
  
  // SharedPreferences实例
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }
  
  /// 初始化设置
  Future<void> _initSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    // 从SharedPreferences加载保存的设置
    final savedProvider = _prefs?.getString('selected_provider') ?? 'openai';
    final savedModel = _prefs?.getString('selected_model') ?? 'gpt-3.5-turbo';
    final savedApiKey = _prefs?.getString('api_key') ?? '';
    final savedOllamaServer = _prefs?.getString('ollama_server') ?? 'http://localhost:11434';
    final savedOllamaModel = _prefs?.getString('ollama_model') ?? 'llama3';
    
    setState(() {
      _selectedProvider = savedProvider;
      _selectedModel = savedModel;
      _apiKeyController.text = savedApiKey;
      _ollamaServerController.text = savedOllamaServer;
      _ollamaModelController.text = savedOllamaModel;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _ollamaServerController.dispose();
    _ollamaModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI设置'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧供应商列表卡片
            Expanded(
              flex: 1,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI 服务商',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildProviderList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 右侧模型设置卡片
            Expanded(
              flex: 2,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '模型设置',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 模型选择或输入
                              const Text(
                                'AI模型',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_selectedProvider != 'ollama')
                                _buildModelSelector()
                              else
                                _buildOllamaModelInput(),
                              
                              const SizedBox(height: 24),
                              
                              // 根据服务商显示不同的配置项
                              if (_selectedProvider != 'ollama') 
                                _buildApiKeyInput()
                              else 
                                _buildOllamaServerInput(),
                              
                              const SizedBox(height: 24),
                              
                              // 操作按钮
                              _buildActionButtons(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建供应商列表
  Widget _buildProviderList() {
    return ListView(
      children: _providerNames.entries.map((entry) {
        final String key = entry.key;
        final String name = entry.value;
        
        return Card(
          elevation: _selectedProvider == key ? 4 : 0,
          color: _selectedProvider == key 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: _selectedProvider == key 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            title: Text(
              name,
              style: TextStyle(
                fontWeight: _selectedProvider == key ? FontWeight.bold : FontWeight.normal,
                color: _selectedProvider == key 
                    ? Theme.of(context).primaryColor 
                    : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedProvider = key;
                // 切换服务商时，重置模型选择
                _selectedModel = _providerModels[key]![0];
              });
            },
          ),
        );
      }).toList(),
    );
  }

  /// 构建模型选择器
  Widget _buildModelSelector() {
    final models = _providerModels[_selectedProvider] ?? ['gpt-3.5-turbo'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedModel,
          isExpanded: true,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedModel = newValue;
              });
            }
          },
          items: models.map<DropdownMenuItem<String>>((String model) {
            return DropdownMenuItem<String>(
              value: model,
              child: Text(model),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 构建Ollama模型输入框
  Widget _buildOllamaModelInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ollamaModelController,
          decoration: const InputDecoration(
            hintText: '请输入Ollama模型名称，如：llama3',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _isDetectingModels ? null : _detectOllamaModels,
              icon: _isDetectingModels 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(_isDetectingModels ? '检测中...' : '检测本地模型'),
            ),
            const SizedBox(width: 12),
            if (_ollamaLocalModels.isNotEmpty)
              Text(
                '找到 ${_ollamaLocalModels.length} 个本地模型',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        if (_ollamaLocalModels.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            '检测到的本地模型:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: min(200, _ollamaLocalModels.length * 50).toDouble(),
            child: ListView.builder(
              itemCount: _ollamaLocalModels.length,
              itemBuilder: (context, index) {
                final model = _ollamaLocalModels[index];
                return Card(
                  child: ListTile(
                    title: Text(model),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _ollamaModelController.text = model;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// 构建API密钥输入框
  Widget _buildApiKeyInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'API密钥',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _apiKeyController,
          decoration: const InputDecoration(
            hintText: '请输入API密钥',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 8),
        const Text(
          '注意：API密钥将被安全存储，仅用于与AI服务通信',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// 构建Ollama服务器地址输入框
  Widget _buildOllamaServerInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ollama服务器地址',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ollamaServerController,
          decoration: const InputDecoration(
            hintText: '请输入Ollama服务器地址，如：http://localhost:11434',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '注意：确保Ollama服务正在运行且可访问',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// 检测Ollama本地模型
  Future<void> _detectOllamaModels() async {
    setState(() {
      _isDetectingModels = true;
      _ollamaLocalModels = [];
    });

    try {
      final baseUrl = _ollamaServerController.text.trim();
      if (baseUrl.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showToast('请先填写Ollama服务器地址');
        }
        return;
      }

      // 确保URL格式正确
      final url = baseUrl.endsWith('/') ? '${baseUrl}api/tags' : '$baseUrl/api/tags';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('models')) {
          final models = List<Map<String, dynamic>>.from(data['models']);
          final modelNames = <String>{};
          
          // 提取模型名称并去重
          for (var model in models) {
            if (model.containsKey('name')) {
              final fullName = model['name'].toString();
              // 直接使用完整模型名称，不做任何处理
              modelNames.add(fullName);
            }
          }
          
          setState(() {
            _ollamaLocalModels = modelNames.toList();
          });
          
          // 自动将检测到的模型添加到配置中
          await _addDetectedModelsToConfig(modelNames.toList(), baseUrl);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showToast('成功检测到 ${modelNames.length} 个本地模型');
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showToast('服务器响应格式不正确');
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showToast('获取模型列表失败: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showToast('检测模型时出错: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isDetectingModels = false;
      });
    }
  }
  
  /// 将检测到的模型添加到配置中
  Future<void> _addDetectedModelsToConfig(List<String> modelNames, String baseUrl) async {
    for (final fullName in modelNames) {
      // 检查模型是否已存在
      final existsInNewManager = _aiModelManager.configuredModels.any(
        (m) => m.provider == 'ollama' && m.name == fullName,
      );
      
      // 如果模型不存在，则添加到新的AI模型管理器
      if (!existsInNewManager) {
        final modelId = _uuid.v4();
        
        // 添加到新的AI模型管理器
        final newModelConfig = AIModelConfig(
          id: modelId,
          name: fullName, // 直接使用完整名称，不做任何处理
          provider: 'ollama',
          apiKey: '',
          baseUrl: baseUrl,
          additionalParams: {'temperature': 0.7},
        );
        
        _aiModelManager.addModel(newModelConfig);
      }
    }
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            '保存设置',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _saveAsModel,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '保存为模型配置',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AIModelListScreen(),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '管理已配置模型',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    // 保存到SharedPreferences
    await _prefs?.setString('selected_provider', _selectedProvider);
    await _prefs?.setString('selected_model', _selectedModel);
    await _prefs?.setString('api_key', _apiKeyController.text);
    await _prefs?.setString('ollama_server', _ollamaServerController.text);
    await _prefs?.setString('ollama_model', _ollamaModelController.text);
    
    if (context.mounted) {
      // 改为Toast提示
      ScaffoldMessenger.of(context).showToast('设置已保存');
    }
  }

  /// 保存为模型配置
  void _saveAsModel() {
    final modelName = _selectedProvider == 'ollama' 
        ? _ollamaModelController.text 
        : _selectedModel;
    
    // 检查是否已存在相同提供商和名称的模型
    final existingModel = _aiModelManager.configuredModels.firstWhereOrNull(
      (m) => m.provider == _selectedProvider && m.name == modelName,
    );
    
    if (existingModel != null) {
      // 如果模型已存在，显示提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showToast('模型配置已存在');
      }
      return;
    }
    
    final modelId = _uuid.v4();
    
    // 保存到新的AI模型管理器
    final newModelConfig = AIModelConfig(
      id: modelId,
      name: modelName, // 确保完整保存模型名称，包括可能的版本信息如"14b"
      provider: _selectedProvider,
      apiKey: _apiKeyController.text,
      baseUrl: _selectedProvider == 'ollama' 
          ? _ollamaServerController.text 
          : _getBaseUrl(_selectedProvider),
      additionalParams: _getAdditionalParams(_selectedProvider),
    );
    
    _aiModelManager.addModel(newModelConfig);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showToast('模型配置已保存');
    }
  }
  
  /// 获取默认基础URL
  String _getBaseUrl(String provider) {
    switch (provider) {
      case 'openai':
        return 'https://api.openai.com/v1';
      case 'anthropic':
        return 'https://api.anthropic.com/v1';
      case 'google':
        return 'https://generativelanguage.googleapis.com/v1beta';
      case 'azure':
        return 'https://your-resource-name.openai.azure.com/openai/deployments';
      default:
        return '';
    }
  }
  
  /// 获取附加参数
  Map<String, dynamic> _getAdditionalParams(String provider) {
    switch (provider) {
      case 'openai':
        return {
          'temperature': 0.7,
          'max_tokens': 2048,
        };
      case 'anthropic':
        return {
          'max_tokens': 1024,
        };
      case 'google':
        return {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
        };
      case 'ollama':
        return {
          'temperature': 0.7,
        };
      case 'azure':
        return {
          'temperature': 0.7,
          'max_tokens': 2048,
        };
      default:
        return {};
    }
  }
}