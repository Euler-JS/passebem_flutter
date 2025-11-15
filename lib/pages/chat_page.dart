import 'package:flutter/material.dart';
import 'package:news_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final messagesData = await AuthService.getChatMessages();
      
      // Converter mensagens da API para o formato local
      final loadedMessages = messagesData.map((msg) {
        // Construir URLs completas para imagens e vídeos se necessário
        String? imageUrl;
        String? videoUrl;
        
        if (msg['image_name'] != null && msg['image_name'].toString().isNotEmpty) {
          imageUrl = 'http://mowosocw4sgwsk84kw4ks40c.62.171.183.132.sslip.io/files/${msg['image_name']}';
        } else if (msg['image'] != null && msg['image'].toString().isNotEmpty) {
          final image = msg['image'].toString();
          imageUrl = image.startsWith('http') ? image : 'http://mowosocw4sgwsk84kw4ks40c.62.171.183.132.sslip.io/files/$image';
        }
        
        if (msg['video_name'] != null && msg['video_name'].toString().isNotEmpty) {
          videoUrl = 'http://mowosocw4sgwsk84kw4ks40c.62.171.183.132.sslip.io/files/${msg['video_name']}';
        } else if (msg['video'] != null && msg['video'].toString().isNotEmpty) {
          final video = msg['video'].toString();
          videoUrl = video.startsWith('http') ? video : 'http://mowosocw4sgwsk84kw4ks40c.62.171.183.132.sslip.io/files/$video';
        }
        
        return ChatMessage(
          id: msg['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          text: msg['text']?.toString() ?? '',
          userId: msg['user']?['_id']?.toString() ?? '',
          userName: msg['user']?['name']?.toString() ?? 'Usuário',
          timestamp: msg['createdAt'] != null 
              ? DateTime.parse(msg['createdAt'].toString())
              : DateTime.now(),
          isMe: false, // Será determinado comparando com ID do usuário atual
          imageUrl: imageUrl,
          videoUrl: videoUrl,
        );
      }).toList();
      
      // Ordenar mensagens por data (mais antigas primeiro, mais recentes no final)
      loadedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      // Obter ID do usuário atual para marcar mensagens próprias
      final currentUser = await AuthService.getStoredUser();
      if (currentUser != null) {
        for (var msg in loadedMessages) {
          msg.isMe = msg.userId == currentUser.id;
        }
      }
      
      setState(() {
        _messages.clear();
        _messages.addAll(loadedMessages);
        _isLoading = false;
      });
      
      // Rolar para o final após carregar mensagens
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text;
    _messageController.clear();

    try {
      final success = await AuthService.sendTextMessage(messageText);
      
      if (success) {
        // Recarregar mensagens para obter a nova mensagem do servidor
        await _loadMessages();
        
        // Rolar para o final após enviar mensagem
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        // Mostrar erro se falhar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao enviar mensagem'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar mensagem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4fd),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Chat Geral',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF607d8b),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF607d8b)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sobre o Chat'),
                  content: const Text(
                    'Chat geral para comunicação entre os usuários do PasseBem.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFffc107),
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma mensagem ainda',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Seja o primeiro a enviar uma mensagem!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
          ),
          
          // Input de mensagem
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Botão de anexos
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF607d8b),
                    ),
                    onPressed: () {
                      _showAttachmentOptions();
                    },
                  ),
                  
                  // Campo de texto
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf0f4fd),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Botão enviar
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFffc107),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!message.isMe)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.userName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF607d8b),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: message.isMe
                    ? const Color(0xFFffc107)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem
                  if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        message.imageUrl!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 250,
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 250,
                            height: 250,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFFffc107),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Vídeo
                  if (message.videoUrl != null && message.videoUrl!.isNotEmpty)
                    Container(
                      width: 250,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.play_circle_outline,
                            size: 60,
                            color: Colors.white,
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Vídeo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Texto
                  if (message.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: message.isMe ? Colors.white : const Color(0xFF212121),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
              child: Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image, color: Color(0xFFffc107)),
              title: const Text('Enviar Imagem'),
              onTap: () {
                Navigator.pop(context);
                _sendImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFFffc107)),
              title: const Text('Enviar Vídeo'),
              onTap: () {
                Navigator.pop(context);
                _sendVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFffc107)),
              title: const Text('Tirar Foto'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _sendImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;
      
      // Mostrar loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFffc107)),
          ),
        );
      }
      
      final success = await AuthService.sendImageMessage(image.path);
      
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        
        if (success) {
          await _loadMessages();
          
          // Rolar para o final
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao enviar imagem'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar imagem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (photo == null) return;
      
      // Mostrar loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFffc107)),
          ),
        );
      }
      
      final success = await AuthService.sendImageMessage(photo.path);
      
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        
        if (success) {
          await _loadMessages();
          
          // Rolar para o final
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao enviar foto'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao tirar foto: $e');
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao tirar foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _sendVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      
      if (video == null) return;
      
      // Mostrar loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFffc107)),
          ),
        );
      }
      
      final success = await AuthService.sendVideoMessage(video.path);
      
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        
        if (success) {
          await _loadMessages();
          
          // Rolar para o final
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao enviar vídeo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao enviar vídeo: $e');
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar vídeo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ChatMessage {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final DateTime timestamp;
  bool isMe;
  final String? imageUrl;
  final String? videoUrl;

  ChatMessage({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.isMe,
    this.imageUrl,
    this.videoUrl,
  });
}
