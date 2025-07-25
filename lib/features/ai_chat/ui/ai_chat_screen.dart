import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../data/models/chat_session.dart';
import '../data/repositories/session_repository.dart';
import 'widgets/session_list.dart';
import '../../../integrations/ai_models/ai_model_manager.dart';
import '../../../integrations/ai_models/ai_service_factory.dart';
import '../../../integrations/ai_models/ai_service_interface.dart';
import '../../../shared/utils/toast_utils.dart';

/// AI聊天屏幕
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final SessionRepository _sessionRepository = SessionRepository();
  final AIModelManager _aiModelManager = AIModelManager();
  late ChatSession _currentSession;
  late InMemoryChatController _chatController;
  bool _isSessionListVisible = true; // 控制会话列表可见性
  bool _isAiResponding = false; // AI是否正在回复

  @override
  void initState() {
    super.initState();
    
    // 创建初始会话
    _currentSession = _sessionRepository.createSession(
      title: '新对话',
    );
    
    _chatController = InMemoryChatController();
    
    // 加载欢迎消息
    _loadWelcomeMessage();
  }
  
  /// 加载欢迎消息
  void _loadWelcomeMessage() {
    _chatController.insertMessage(
      TextMessage(
        id: 'welcome_msg_${_currentSession.id}',
        authorId: 'ai_id',
        createdAt: DateTime.now().toUtc(),
        text: '你好！我是AI助手，有什么我可以帮你的吗？',
      ),
    );
  }
  
  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 会话列表 (根据状态显示或隐藏)
          if (_isSessionListVisible)
            SessionList(
              sessionRepository: _sessionRepository,
              onCreateNewSession: _createNewSession,
              onSessionSelected: _switchToSession,
            ),
          
          // 聊天区域
          Expanded(
            child: Column(
              children: [
                // 顶部AppBar
                _buildAppBar(),
                
                // 聊天内容
                Expanded(
                  child: Chat(
                    chatController: _chatController,
                    currentUserId: 'user_id',
                    onMessageSend: _handleMessageSend,
                    resolveUser: (id) async {
                      if (id == 'user_id') {
                        return User(id: id, name: 'User');
                      } else {
                        return User(id: id, name: 'AI Assistant');
                      }
                    },
                  ),
                ),
                
                // AI正在回复时显示指示器
                if (_isAiResponding)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('AI正在思考中...'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建顶部AppBar
  Widget _buildAppBar() {
    return AppBar(
      title: Text(_currentSession.title),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(_isSessionListVisible ? Icons.menu_open : Icons.menu),
        onPressed: () {
          setState(() {
            _isSessionListVisible = !_isSessionListVisible;
          });
        },
        tooltip: _isSessionListVisible ? '隐藏会话列表' : '显示会话列表',
      ),
      actions: [
        // 模型选择按钮
        PopupMenuButton<String>(
          icon: const Icon(Icons.smart_toy),
          tooltip: '选择AI模型',
          onSelected: _changeModel,
          itemBuilder: (BuildContext context) {
            // 使用新的模型管理器中的模型
            final models = _aiModelManager.configuredModels;
            
            // 按提供商分组
            final Map<String, List<AIModelConfig>> groupedModels = {};
            for (final model in models) {
              if (!groupedModels.containsKey(model.provider)) {
                groupedModels[model.provider] = [];
              }
              groupedModels[model.provider]!.add(model);
            }
            
            final List<PopupMenuEntry<String>> menuItems = [];
            
            groupedModels.forEach((provider, models) {
              // 添加提供商标题
              menuItems.add(
                PopupMenuItem<String>(
                  enabled: false,
                  height: 30,
                  child: Text(
                    _getProviderDisplayName(provider),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
              
              // 添加模型项
              menuItems.addAll(models.map((model) {
                return PopupMenuItem<String>(
                  value: model.id,
                  child: Row(
                    children: [
                      if (_currentSession.model == model.name)
                        const Icon(Icons.check, size: 18, color: Colors.green)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(model.name)),
                    ],
                  ),
                );
              }).toList());
              
              // 添加分隔符（除了最后一组）
              if (provider != groupedModels.keys.last) {
                menuItems.add(const PopupMenuDivider(height: 10));
              }
            });
            
            // 如果没有配置模型，显示提示
            if (menuItems.isEmpty) {
              menuItems.add(
                const PopupMenuItem<String>(
                  enabled: false,
                  child: Text('暂无可用模型，请先配置'),
                ),
              );
            }
            
            return menuItems;
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _renameSession,
          tooltip: '重命名会话',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showMoreOptions,
          tooltip: '更多选项',
        ),
      ],
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
  
  /// 创建新会话
  void _createNewSession() {
    setState(() {
      _currentSession = _sessionRepository.createSession(
        title: '新对话',
      );
      
      _chatController = InMemoryChatController();
      _loadWelcomeMessage();
    });
  }
  
  /// 切换到指定会话
  void _switchToSession(ChatSession session) {
    setState(() {
      _currentSession = session;
      _sessionRepository.setActiveSession(session);
      
      _chatController = InMemoryChatController();
      
      // 加载会话消息
      for (var message in session.messages) {
        if (message is types.TextMessage) {
          _chatController.insertMessage(
            TextMessage(
              id: message.id,
              authorId: message.author.id,
              createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? DateTime.now().millisecondsSinceEpoch).toUtc(),
              text: message.text,
            ),
          );
        }
      }
    });
  }
  
  /// 更改会话模型
  void _changeModel(String modelId) {
    // 查找选中的模型
    final selectedModel = _aiModelManager.configuredModels
        .firstWhereOrNull((model) => model.id == modelId);
    
    if (selectedModel == null) {
      return; // 没找到则返回
    }
    
    setState(() {
      _currentSession = _sessionRepository.updateSession(
        _currentSession.copyWith(
          model: selectedModel.name, // 确保完整使用模型名称，包括版本信息如"14b"
          updatedAt: DateTime.now(),
        ),
      );
    });
  }
  
  /// 处理消息发送
  void _handleMessageSend(String text) {
    // 创建用户消息
    final userMessage = TextMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
      authorId: 'user_id',
      createdAt: DateTime.now().toUtc(),
      text: text,
    );
    
    _chatController.insertMessage(userMessage);
    
    // 保存到会话
    // 注意：这里需要转换flutter_chat-types的Message为flutter_chat_core的Message
    _sessionRepository.addMessageToSession(
      _currentSession.id,
      types.TextMessage(
        author: const types.User(id: 'user_id', firstName: 'User'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: userMessage.id,
        text: userMessage.text,
      ),
    );
    
    // 获取AI回复
    _getAiResponse(text);
  }
  
  /// 获取AI回复
  Future<void> _getAiResponse(String userMessage) async {
    setState(() {
      _isAiResponding = true;
    });
    
    try {
      // 构建对话历史
      final List<Map<String, String>> history = [];
      // 使用会话中的消息而不是调用不存在的方法
      final messages = _currentSession.messages;
      
      for (var message in messages) {
        if (message is types.TextMessage) {
          if (message.author.id == 'user_id') {
            history.add({'role': 'user', 'content': message.text});
          } else if (message.author.id == 'ai_id') {
            history.add({'role': 'assistant', 'content': message.text});
          }
        }
      }
      
      // 查找当前会话使用的模型
      dynamic currentModel;
      
      // 在AI模型管理器中查找
      try {
        currentModel = _aiModelManager.configuredModels.firstWhere(
          (model) => model.name == _currentSession.model, // 确保完整匹配模型名称，包括版本信息如"14b"
        );
      } catch (e) {
        // 都没找到则使用默认模型
        currentModel = null;
      }
      
      // 使用AI服务工厂发送消息
      final responseText = await AIServiceFactory.sendMessage(
        userMessage,
        history,
        currentModel ?? _aiModelManager.configuredModels.first, // 如果找不到指定模型，则使用第一个可用模型
      );
      
      // 创建AI回复消息
      final aiMessage = TextMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
        authorId: 'ai_id',
        createdAt: DateTime.now().toUtc(),
        text: responseText,
      );
      
      _chatController.insertMessage(aiMessage);
      
      // 保存AI消息到会话
      _sessionRepository.addMessageToSession(
        _currentSession.id,
        types.TextMessage(
          author: const types.User(id: 'ai_id', firstName: 'AI Assistant'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: aiMessage.id,
          text: aiMessage.text,
        ),
      );
      
      // 更新会话标题（如果还是默认标题）
      if (_currentSession.title == '新对话') {
        final newTitle = userMessage.length > 20 
            ? '${userMessage.substring(0, 20)}...' 
            : userMessage;
        
        setState(() {
          _currentSession = _sessionRepository.updateSession(
            _currentSession.copyWith(
              title: newTitle,
              updatedAt: DateTime.now(),
            ),
          );
        });
      } else {
        _sessionRepository.updateSession(
          _currentSession.copyWith(
            updatedAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      // 处理错误
      String errorMessage = '抱歉，我在回复时遇到了问题';
      
      // 提供更具体的错误信息
      if (e is AIServiceException) {
        errorMessage = 'AI服务错误: ${e.message}';
      } else {
        errorMessage = '未知错误: ${e.toString()}';
      }
      
      final aiMessage = TextMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
        authorId: 'ai_id',
        createdAt: DateTime.now().toUtc(),
        text: errorMessage,
      );
      
      _chatController.insertMessage(aiMessage);
      
      // 保存错误消息到会话
      _sessionRepository.addMessageToSession(
        _currentSession.id,
        types.TextMessage(
          author: const types.User(id: 'ai_id', firstName: 'AI Assistant'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: aiMessage.id,
          text: aiMessage.text,
        ),
      );
    } finally {
      setState(() {
        _isAiResponding = false;
      });
    }
  }
  
  /// 重命名会话
  void _renameSession() {
    final TextEditingController controller = TextEditingController(
      text: _currentSession.title,
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('重命名会话'),
          content: TextField(
            controller: controller,
            autofocus: true,
            onSubmitted: (value) {
              _confirmRenameSession(value);
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                _confirmRenameSession(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
  
  /// 确认重命名会话
  void _confirmRenameSession(String newTitle) {
    if (newTitle.trim().isNotEmpty) {
      setState(() {
        _currentSession = _sessionRepository.updateSession(
          _currentSession.copyWith(
            title: newTitle.trim(),
            updatedAt: DateTime.now(),
          ),
        );
      });
    }
  }
  
  /// 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除会话'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteCurrentSession();
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('导出对话'),
              onTap: () {
                Navigator.of(context).pop();
                _exportConversation();
              },
            ),
          ],
        );
      },
    );
  }
  
  /// 删除当前会话
  void _deleteCurrentSession() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除会话"${_currentSession.title}"吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sessionRepository.deleteSession(_currentSession.id);
                _createNewSession(); // 创建一个新会话
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
  
  /// 导出对话
  void _exportConversation() {
    // 在实际应用中，这里会实现导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('对话导出功能待实现')),
    );
  }
}