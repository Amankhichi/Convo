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

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _messageController;
  final FocusNode _focusNode = FocusNode();
  // bool isMe = false;
  bool emoji = false;
  bool mssgSelected = false;
  Set<String> mssgIdSelected = {};
  Set<String> mssgCopySelected = {};
  // bool seen = false;

  bool mssgEdit = false;
  String? editingMessageId;

  bool isReplying = false;
  String? replyMessage;
  int? replyMessageId;

  Future<void> makeCall(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);

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
    context.read<ChatBloc>().add(
      ChatEvent.getMssg(receiverId: widget.user.id.toString()),
    );

    Future.delayed(Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleReply(msg) {
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

  //   @override
  // void dispose() {
  //   super.dispose();

  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.popUntil(context, (route) => route.isFirst);
            return false; // prevent default back
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor(context),

            /// APP BAR
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: CustomChatAppBar(
                user: widget.user,
                mssgSelected: mssgSelected,
                mssgIdSelected: mssgIdSelected,
                mssgCopySelected: mssgCopySelected,
                state: state,
                onBackPressed: () => mssgSelected
                    ? setState(() {
                        _focusNode.unfocus();
                        mssgSelected = false;
                        mssgIdSelected.clear();
                      })
                    : Navigator.pop(context),
                onProfileTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: ContactUserProfilePage(user: widget.user),
                      beginOffset: const Offset(-1, 0),
                    ),
                  );
                },
                onVoiceCall: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoiceCallPage(user: widget.user),
                    ),
                  );
                },
                onVideoCall: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.scale,
                      alignment: Alignment.bottomCenter,
                      child: VideoCallPage(user: widget.user),
                    ),
                  );
                },
                onCopyMessages: () async {
                  if (mssgCopySelected.isEmpty) return;

                  final copyText = mssgCopySelected.join("\n");

                  await Clipboard.setData(ClipboardData(text: copyText));

                  Fluttertoast.showToast(
                    msg: "Text Copied",
                    gravity: ToastGravity.CENTER,
                  );

                  setState(() {
                    mssgSelected = false;
                    mssgCopySelected.clear();
                  });
                },
                onDeleteMessages: () {
                  for (final id in mssgIdSelected) {
                    context.read<ChatBloc>().add(
                      ChatEvent.deletMssg(mssId: int.parse(id)),
                    );
                  }

                  setState(() {
                    mssgSelected = false;
                    mssgIdSelected.clear();
                  });
                },
                onEditMessage: (messageId) {
                  final selectedMsg = state.messages.firstWhere(
                    (e) => e.id.toString() == messageId,
                  );
                  _messageController.text = selectedMsg.message;

                  setState(() {
                    mssgEdit = true;
                    editingMessageId = messageId;
                    mssgSelected = false;
                    mssgIdSelected.clear();
                  });
                },
              ),
            ),

            /// BODY
          body: ChatBodyContainer(
  isDeviceThemeDark: isDeviceThemeDark,
  child: ChatMainColumn(
    messages: state.messages,
    profile: context.read<LoginBloc>().state.profile,
    mssgSelected: mssgSelected,
    mssgIdSelected: mssgIdSelected,
    mssgCopySelected: mssgCopySelected,
    isReplying: isReplying,
    replyMessage: replyMessage,
    emoji: emoji,
    mssgEdit: mssgEdit,
    editingMessageId: editingMessageId,
    messageController: _messageController,  
    focusNode: _focusNode,
    onLongPressMessage: (msg) {
      setState(() {
        mssgSelected = true;
        mssgIdSelected.add(msg.id.toString());
        mssgCopySelected.add(msg.message.toString());
      });
    },
onTapMessage: (msg) {
  if (mssgSelected) {
    setState(() {
      final id = msg.id.toString();
      if (mssgIdSelected.contains(id)) {
        mssgIdSelected.remove(id);
        if (mssgIdSelected.isEmpty) {
          mssgSelected = false;
        }
      } else {
        mssgIdSelected.add(id);
        mssgCopySelected.add(msg.message.toString());
      }
    });
  } else {
    // ✅ Handle emoji hide when tapping message (original logic)
    setState(() => emoji = false);
  }
},
    onReplyCancel: () {
      setState(() {
        isReplying = false;
        replyMessage = null;
        replyMessageId = null;
      });
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    },
onEmojiToggle: () {
  setState(() => emoji = !emoji); // ✅ State managed in parent
  
  if (emoji) {
    _focusNode.unfocus(); // ✅ Use passed focusNode
  } else {
    _focusNode.requestFocus(); // ✅ Use passed focusNode
  }
},
    onMessageChanged: (v) {
      if (mssgEdit && v.trim().isEmpty) {
        setState(() {
          mssgEdit = false;
          editingMessageId = null;
        });
      }
    },
    onEditMessage: () {
      if (editingMessageId == null) return;
      context.read<ChatBloc>().add(
        ChatEvent.editMssg(
          mssgId: int.parse(editingMessageId!),
          newMssg: _messageController.text.trim(),
        ),
      );
      _messageController.clear();
      setState(() {
        mssgEdit = false;
        editingMessageId = null;
      });
    },
    onSendMessage: () {
      context.read<ChatBloc>().add(
        ChatEvent.sendMssg(
          mssg: _messageController.text.trim(),
          receiverId: widget.user.id.toString(),
          replyTo: replyMessageId,
        ),
      );
      isReplying = false;
      _messageController.clear();
    },
    onHandleReply: _handleReply,
    user: widget.user,
  ),
),
          ),
        );
      },
    );
  }
}
