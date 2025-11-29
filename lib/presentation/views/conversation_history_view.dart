import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/conversation_log.dart';
import '../providers/services_provider.dart';

/// View for displaying conversation history
class ConversationHistoryView extends ConsumerStatefulWidget {
  const ConversationHistoryView({super.key});

  @override
  ConsumerState<ConversationHistoryView> createState() => _ConversationHistoryViewState();
}

class _ConversationHistoryViewState extends ConsumerState<ConversationHistoryView> {
  List<ConversationSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    final logService = ref.read(conversationLogServiceProvider);
    final sessions = await logService.getAllSessions();

    setState(() {
      _sessions = sessions.reversed.toList(); // Show newest first
      _isLoading = false;
    });
  }

  Future<void> _deleteSession(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除会话'),
        content: const Text('确定要删除这个会话吗？相关的图片也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final logService = ref.read(conversationLogServiceProvider);
      await logService.deleteSession(sessionId);
      await _loadSessions();
    }
  }

  Future<void> _deleteAllSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除所有会话'),
        content: const Text('确定要删除所有会话吗？这个操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('全部删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final logService = ref.read(conversationLogServiceProvider);
      await logService.deleteAllSessions();
      await _loadSessions();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('对话历史'),
        actions: [
          if (_sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _deleteAllSessions,
              tooltip: '删除所有',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(
                  child: Text(
                    '暂无对话记录',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSessions,
                  child: ListView.builder(
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return _SessionCard(
                        session: session,
                        onDelete: () => _deleteSession(session.id),
                        formatDateTime: _formatDateTime,
                      );
                    },
                  ),
                ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ConversationSession session;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDateTime;

  const _SessionCard({
    required this.session,
    required this.onDelete,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          '会话 - ${formatDateTime(session.startTime)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${session.messages.length} 条消息'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: session.messages.length,
            itemBuilder: (context, index) {
              final message = session.messages[index];
              return _MessageTile(message: message);
            },
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final ConversationMessage message;

  const _MessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isUser ? Colors.blue : Colors.green,
            child: Icon(
              isUser ? Icons.person : Icons.smart_toy,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isUser ? '用户' : 'Gemini',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(message.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ContentTypeChip(contentType: message.contentType),
                  ],
                ),
                const SizedBox(height: 4),
                if (message.content != null) Text(message.content!),
                if (message.imagePath != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(message.imagePath!),
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text('图片加载失败'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _ContentTypeChip extends StatelessWidget {
  final MessageContentType contentType;

  const _ContentTypeChip({required this.contentType});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (contentType) {
      case MessageContentType.text:
        label = '文本';
        color = Colors.blue;
        break;
      case MessageContentType.voice:
        label = '语音';
        color = Colors.orange;
        break;
      case MessageContentType.textWithImage:
        label = '文本+图片';
        color = Colors.purple;
        break;
      case MessageContentType.voiceWithImage:
        label = '语音+图片';
        color = Colors.pink;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
