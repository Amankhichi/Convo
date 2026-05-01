import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/chat/presentation/widgets/mssg_widgets.dart';
import 'package:convo/features/chat/presentation/widgets/replybar.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMainColumn extends StatefulWidget {
  final List<dynamic> messages;
  final dynamic profile;
  final bool mssgSelected;
  final Set<String> mssgIdSelected;
  final Set<String> mssgCopySelected;
  final bool isReplying;
  final String? replyMessage;
  final bool emoji;
  final bool mssgEdit;
  final String? editingMessageId;
  final TextEditingController messageController;
  final FocusNode focusNode;
  final Function(dynamic) onLongPressMessage;
  final Function(dynamic) onTapMessage;
  final VoidCallback onReplyCancel;
  final VoidCallback onEmojiToggle;
  final Function(String) onMessageChanged;
  final VoidCallback onEditMessage;
  final VoidCallback onSendMessage;
  final Function(dynamic) onHandleReply;
  final UserModel user;

  const ChatMainColumn({
    Key? key,
    required this.messages,
    required this.profile,
    required this.mssgSelected,
    required this.mssgIdSelected,
    required this.mssgCopySelected,
    required this.isReplying,
    required this.replyMessage,
    required this.emoji,
    required this.mssgEdit,
    required this.editingMessageId,
    required this.messageController,
    required this.focusNode,
    required this.onLongPressMessage,
    required this.onTapMessage,
    required this.onReplyCancel,
    required this.onEmojiToggle,
    required this.onMessageChanged,
    required this.onEditMessage,
    required this.onSendMessage,
    required this.onHandleReply,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatMainColumn> createState() => _ChatMainColumnState();
}

class _ChatMainColumnState extends State<ChatMainColumn> {

  @override
  void initState() {
    super.initState();

    /// ✅ instant icon update
    widget.messageController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildMessagesList(context)),

        if (widget.isReplying) _buildReplyBar(context),

        _buildInputBar(context),

        if (widget.emoji &&
            MediaQuery.of(context).viewInsets.bottom == 0)
          _buildEmojiPicker(context),
      ],
    );
  }

  Widget _buildMessagesList(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, sstate) {
        return widget.messages.isEmpty
            ? const SizedBox()
            : ListView.builder(
                reverse: true,
                itemCount: widget.messages.length,
                itemBuilder: (context, index) =>
                    _buildMessageItem(index),
              );
      },
    );
  }

  Widget _buildMessageItem(int index) {
    final msg =
        widget.messages[widget.messages.length - index - 1];

    final bool isMe =
        msg.senderId.toString() ==
        widget.profile?.id.toString();

    return Dismissible(
      key: Key(msg.id.toString()),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        widget.onHandleReply(msg);
        return false;
      },
      background: _buildReplyBackground(),
      child: _buildMessageGestureDetector(msg, isMe),
    );
  }

  Widget _buildReplyBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Icon(
        Icons.reply,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildMessageGestureDetector(
      dynamic msg,
      bool isMe,
      ) {
    return GestureDetector(
      onLongPress: () => widget.onLongPressMessage(msg),
      onTap: () => widget.onTapMessage(msg),
      child: Row(
        children: [
          if (widget.mssgSelected)
            _buildSelectionIcon(msg),

          Expanded(
            child: _buildMessageWidget(msg, isMe),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionIcon(dynamic msg) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Icon(
        widget.mssgIdSelected.contains(msg.id.toString())
            ? Icons.check_circle
            : Icons.radio_button_unchecked,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildMessageWidget(dynamic msg, bool isMe) {
    return MssgWidgets(
      chatStatus: msg.id == 0
          ? ChatStatus.sending
          : msg.seen
          ? ChatStatus.seen
          : ChatStatus.send,
      isMe: isMe,
      message: msg.message,
      replyMessage: msg.reply?.message,
      time: msg.createdAt,
    );
  }

  Widget _buildReplyBar(BuildContext context) {
    return ReplyBar(
      replyMessage: widget.replyMessage ?? "",
      onCancel: widget.onReplyCancel,
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return InputBar(
      messageController: widget.messageController,
      focusNode: widget.focusNode,
      emoji: widget.emoji,
      mssgEdit: widget.mssgEdit,

      /// ✅ instant update while typing
      onMessageChanged: (value) {
        setState(() {});
        widget.onMessageChanged(value);
      },

      onEmojiToggle: () {
        setState(() {});
        widget.onEmojiToggle();
      },

      onEditMessage: () {
        widget.onEditMessage();
        setState(() {});
      },

      onSendMessage: () {
        widget.onSendMessage();

        /// ✅ instant mic/send icon change
        Future.delayed(
          const Duration(milliseconds: 10),
              () {
            if (mounted) {
              setState(() {});
            }
          },
        );
      },

      sendButtonColor: AppColors.sendBT,

      backgroundColor:
      (context) => AppColors.backgroundColor(context),

      iconColor: AppColors.iconColor,

      chatProfileColor:
      (context) => AppColors.chatProfileColor(context),
    );
  }

  Widget _buildEmojiPicker(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 50),
      offset:
      widget.emoji ? Offset.zero : const Offset(0, 1),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.35,
        child: EmojiPicker(
          textEditingController: widget.messageController,
          config: const Config(
            categoryViewConfig: CategoryViewConfig(
              initCategory: Category.SMILEYS,
            ),
          ),
        ),
      ),
    );
  }
}