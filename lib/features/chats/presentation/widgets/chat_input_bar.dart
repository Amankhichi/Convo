import 'dart:async';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/network/chat_realtime_service.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/presentation/widgets/reply_preview_widget.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final int activeChatId;
  final MessageEntity? replyingMessage;
  final MessageEntity? editingMessage;
  final bool isRecordingAudio;
  final int recordingSeconds;
  final VoidCallback onCancelReply;
  final VoidCallback onCancelEditing;
  final VoidCallback onCancelAudioRecording;
  final VoidCallback onToggleAudioRecording;
  final ValueChanged<String> onSendMessage;
  final VoidCallback onOpenAttachmentSheet;

  const ChatInputBar({
    super.key,
    required this.activeChatId,
    this.replyingMessage,
    this.editingMessage,
    required this.isRecordingAudio,
    required this.recordingSeconds,
    required this.onCancelReply,
    required this.onCancelEditing,
    required this.onCancelAudioRecording,
    required this.onToggleAudioRecording,
    required this.onSendMessage,
    required this.onOpenAttachmentSheet,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late TextEditingController _controller;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingMessage != null && widget.editingMessage != oldWidget.editingMessage) {
      _controller.text = widget.editingMessage!.content;
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {}); // Local rebuild of input bar only!
    if (widget.activeChatId <= 0) return;

    _typingTimer?.cancel();
    sl<ChatRealtimeService>().sendTypingNotification(widget.activeChatId, true);
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      sl<ChatRealtimeService>().sendTypingNotification(widget.activeChatId, false);
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text);
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.editingMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            child: Row(
              children: [
                const Icon(Icons.edit, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Editing: ${widget.editingMessage!.content}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _controller.clear();
                    widget.onCancelEditing();
                  },
                ),
              ],
            ),
          ),
        if (widget.replyingMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            child: ReplyPreviewWidget(
              replyContent: widget.replyingMessage!.content,
              isMe: false,
              onCancel: widget.onCancelReply,
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: widget.isRecordingAudio
              ? Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: widget.onCancelAudioRecording,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "Recording: ${widget.recordingSeconds}s",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: widget.onToggleAudioRecording,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.sentiment_satisfied_alt, color: AppColors.primary),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: AppColors.primary),
                      onPressed: widget.onOpenAttachmentSheet,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(color: AppColors.textColor(context)),
                          decoration: const InputDecoration(
                            hintText: "Message...",
                            border: InputBorder.none,
                          ),
                          onChanged: _onTextChanged,
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: Icon(
                          _controller.text.trim().isEmpty ? Icons.mic : Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          if (_controller.text.trim().isEmpty) {
                            widget.onToggleAudioRecording();
                          } else {
                            _handleSend();
                          }
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
