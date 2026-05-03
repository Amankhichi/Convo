import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/const.dart/slide_page_route.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/chat/presentation/pages/contact_user_profile_page.dart';
import 'package:convo/features/chat/presentation/pages/video_call_page.dart';
import 'package:convo/features/chat/presentation/pages/voice_call_page.dart';
import 'package:convo/features/chat/presentation/widgets/chat_body_container.dart';
import 'package:convo/features/chat/presentation/widgets/chat_main_column.dart';
import 'package:convo/features/chat/presentation/widgets/custom_chat_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/features/chat/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:page_transition/page_transition.dart';

class ChatPage extends StatefulWidget {
  final UserModel user;

  const ChatPage({
    super.key,
    required this.user,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _messageController;

  final FocusNode _focusNode = FocusNode();
  bool emoji = false;
  bool isMessageSelected = false;

  bool hasText = false;

  final Set<String> selectedMessageIds = {};

  final Set<String> selectedMessages = {};

  bool isEditingMessage = false;

  String? editingMessageId;

  bool isReplying = false;

  String? replyMessage;

  int? replyMessageId;

  Future<void> makeCall(String phone) async {
    final Uri callUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch $callUri';
    }
  }

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();

    _messageController.addListener(() {
      if (mounted) {
        setState(() {
          hasText = _messageController.text.trim().isNotEmpty;
        });
      }
    });

    context.read<ChatBloc>().add(
          ChatEvent.getMssg(
            receiverId: widget.user.id.toString(),
          ),
        );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleReply(dynamic msg) {
    setState(() {
      isReplying = true;
      replyMessage = msg.message;
      replyMessageId = msg.id;
    });

    FocusScope.of(context).unfocus();

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      isMessageSelected = false;
      selectedMessageIds.clear();
      selectedMessages.clear();
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    context.read<ChatBloc>().add(
          ChatEvent.sendMssg(
            mssg: text,
            receiverId: widget.user.id.toString(),
            replyTo: replyMessageId,
          ),
        );

    _messageController.clear();

    setState(() {
      isReplying = false;
      replyMessage = null;
      replyMessageId = null;
    });
  }

  void _editMessage() {
    if (editingMessageId == null) return;

    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    context.read<ChatBloc>().add(
          ChatEvent.editMssg(
            mssgId: int.parse(editingMessageId!),
            newMssg: text,
          ),
        );

    _messageController.clear();

    setState(() {
      isEditingMessage = false;
      editingMessageId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (isMessageSelected) {
              _clearSelection();
              return false;
            }

            Navigator.pop(context);

            return false;
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor(context),

            /// APP BAR
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70),

              child: CustomChatAppBar(
                user: widget.user,
                mssgSelected: isMessageSelected,
                mssgIdSelected: selectedMessageIds,
                mssgCopySelected: selectedMessages,
                state: state,

                onBackPressed: () {
                  if (isMessageSelected) {
                    _focusNode.unfocus();
                    _clearSelection();
                  } else {
                    Navigator.pop(context);
                  }
                },

                onProfileTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: ContactUserProfilePage(
                        user: widget.user,
                      ),
                      beginOffset: const Offset(-1, 0),
                    ),
                  );
                },

                onVoiceCall: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoiceCallPage(
                        user: widget.user,
                      ),
                    ),
                  );
                },

                onVideoCall: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.scale,
                      alignment: Alignment.bottomCenter,
                      child: VideoCallPage(
                        user: widget.user,
                      ),
                    ),
                  );
                },

                onCopyMessages: () async {
                  if (selectedMessages.isEmpty) return;

                  final copyText = selectedMessages.join("\n");

                  await Clipboard.setData(
                    ClipboardData(text: copyText),
                  );

                  Fluttertoast.showToast(
                    msg: "Text Copied",
                    gravity: ToastGravity.CENTER,
                  );

                  _clearSelection();
                },

                onDeleteMessages: () {
                  for (final id in selectedMessageIds) {
                    context.read<ChatBloc>().add(
                          ChatEvent.deletMssg(
                            mssId: int.parse(id),
                          ),
                        );
                  }

                  _clearSelection();
                },

                onEditMessage: (messageId) {
                  final index = state.messages.indexWhere(
                    (e) => e.id.toString() == messageId,
                  );

                  if (index == -1) return;

                  final selectedMsg = state.messages[index];

                  _messageController.text = selectedMsg.message;

                  setState(() {
                    isEditingMessage = true;
                    editingMessageId = messageId;

                    isMessageSelected = false;

                    selectedMessageIds.clear();

                    selectedMessages.clear();
                  });

                  Future.delayed(
                    const Duration(milliseconds: 100),
                    () {
                      if (mounted) {
                        _focusNode.requestFocus();
                      }
                    },
                  );
                },
              ),
            ),

            /// BODY
            body: ChatBodyContainer(
              isDeviceThemeDark: isDeviceThemeDark,

              child: ChatMainColumn(
                messages: state.messages,

                profile: context.read<LoginBloc>().state.profile,

                mssgSelected: isMessageSelected,

                mssgIdSelected: selectedMessageIds,

                mssgCopySelected: selectedMessages,

                isReplying: isReplying,

                replyMessage: replyMessage,

                emoji: emoji,

                mssgEdit: isEditingMessage,

                editingMessageId: editingMessageId,

                messageController: _messageController,

                focusNode: _focusNode,

                user: widget.user,

                onLongPressMessage: (msg) {
                  FocusScope.of(context).unfocus();

                  setState(() {
                    isMessageSelected = true;

                    selectedMessageIds.add(
                      msg.id.toString(),
                    );

                    selectedMessages.add(
                      msg.message.toString(),
                    );
                  });
                },

                onTapMessage: (msg) {
                  if (isMessageSelected) {
                    setState(() {
                      final id = msg.id.toString();

                      if (selectedMessageIds.contains(id)) {
                        selectedMessageIds.remove(id);

                        selectedMessages.remove(
                          msg.message.toString(),
                        );

                        if (selectedMessageIds.isEmpty) {
                          isMessageSelected = false;
                        }
                      } else {
                        selectedMessageIds.add(id);

                        selectedMessages.add(
                          msg.message.toString(),
                        );
                      }
                    });
                  } else {
                    setState(() {
                      emoji = false;
                    });
                  }
                },

                onReplyCancel: () {
                  setState(() {
                    isReplying = false;
                    replyMessage = null;
                    replyMessageId = null;
                  });

                  FocusScope.of(context).unfocus();

                  Future.delayed(
                    const Duration(milliseconds: 50),
                    () {
                      if (mounted) {
                        FocusScope.of(context).requestFocus(
                          _focusNode,
                        );
                      }
                    },
                  );
                },

                onEmojiToggle: () {
                  setState(() {
                    emoji = !emoji;
                  });

                  if (emoji) {
                    _focusNode.unfocus();
                  } else {
                    _focusNode.requestFocus();
                  }
                },

                onMessageChanged: (v) {
                  if (isEditingMessage &&
                      v.trim().isEmpty) {
                    setState(() {
                      isEditingMessage = false;
                      editingMessageId = null;
                    });
                  }
                },

                onEditMessage: _editMessage,

                onSendMessage: _sendMessage,

                onHandleReply: _handleReply,
              ),
            ),
          ),
        );
      },
    );
  }
}