import 'package:flutter/material.dart';

import '../../../integrations/ai_models/ai_model_manager.dart';
import '../../../integrations/ai_models/ai_service_factory.dart';
import '../../../integrations/ai_models/ai_service_interface.dart';
import '../../../shared/utils/toast_utils.dart';

class AIModelListScreen extends StatefulWidget {
  const AIModelListScreen({super.key});

  @override
  State<AIModelListScreen> createState() => _AIModelListScreenState();
}

class _AIModelListScreenState extends State<AIModelListScreen> {
  final AIModelManager _aiModelManager = AIModelManager();
  
  // 正在测试的模型ID
  String? _testingModelId;
  
  // 测试结果
  Map<String, String> _testResults = {};

  @override
  void initState() {
    super.initState();
    // 初始化AI模型管理器
    _aiModelManager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI模型管理'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '已配置的AI模型',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildModelList(),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建模型列表
  Widget _buildModelList() {
    final models = _aiModelManager.configuredModels;
    
    if (models.isEmpty) {
      return const Center(
        child: Text(
          '暂无配置的AI模型',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_getProviderDisplayName(model.provider)} (${model.provider})',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteModel(model.id),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _testingModelId == model.id 
                          ? null 
                          : () => _testModelConnection(model),
                      child: _testingModelId == model.id
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('测试连接'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _setAsCurrentModel(model),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _aiModelManager.currentModel?.id == model.id
                            ? Colors.green
                            : null,
                      ),
                      child: Text(
                        _aiModelManager.currentModel?.id == model.id
                            ? '当前使用'
                            : '设为当前',
                      ),
                    ),
                  ],
                ),
                if (_testResults.containsKey(model.id)) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _testResults[model.id] == 'success'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _testResults[model.id] == 'success'
                              ? Icons.check_circle
                              : Icons.error,
                          color: _testResults[model.id] == 'success'
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _testResults[model.id] == 'success'
                                ? '连接成功'
                                : '连接失败: ${_testResults[model.id]}',
                            style: TextStyle(
                              color: _testResults[model.id] == 'success'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// 获取提供商显示名称
  String _getProviderDisplayName(String provider) {
    switch (provider) {
      case 'openai':
        return 'OpenAI';
      case 'anthropic':
        return 'Anthropic';
      case 'google':
        return 'Google';
      case 'azure':
        return 'Azure OpenAI';
      case 'ollama':
        return 'Ollama';
      default:
        return provider;
    }
  }
  
  /// 测试模型连接
  Future<void> _testModelConnection(AIModelConfig model) async {
    setState(() {
      _testingModelId = model.id;
    });
    
    try {
      final result = await AIServiceFactory.validateConfig(model);
      setState(() {
        _testResults[model.id] = result ? 'success' : '验证失败';
        _testingModelId = null;
      });
    } on AIServiceException catch (e) {
      setState(() {
        _testResults[model.id] = e.message;
        _testingModelId = null;
      });
    } catch (e) {
      setState(() {
        _testResults[model.id] = '未知错误: ${e.toString()}';
        _testingModelId = null;
      });
    }
  }
  
  /// 设置为当前模型
  void _setAsCurrentModel(AIModelConfig model) {
    _aiModelManager.setCurrentModel(model.id);
    ScaffoldMessenger.of(context).showToast('已设置为当前模型: ${model.name}');
    setState(() {});
  }
  
  /// 确认删除模型
  void _confirmDeleteModel(String modelId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这个模型配置吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteModel(modelId);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
  
  /// 删除模型
  void _deleteModel(String modelId) {
    _aiModelManager.removeModel(modelId);
    setState(() {
      _testResults.remove(modelId);
    });
    
    ScaffoldMessenger.of(context).showToast('模型已删除');
  }
}