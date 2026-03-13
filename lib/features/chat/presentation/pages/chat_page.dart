// import 'package:convo/core/const.dart/constant.dart';
// import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
// import 'package:convo/features/chat/presentation/pages/video_call_page.dart';
// import 'package:convo/features/chat/presentation/pages/voice_call_page.dart';
// import 'package:convo/features/chat/presentation/widgets/chat_appbar_widget.dart';
// import 'package:convo/features/chat/presentation/widgets/chat_input_field_widget.dart';
// import 'package:convo/features/chat/presentation/widgets/chat_message_list.dart';
// import 'package:convo/features/chat/presentation/widgets/emoji_picker_widget.dart';
// import 'package:convo/features/chat/presentation/widgets/reply_preview_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:convo/core/model/user_model.dart';
// import 'package:convo/core/const.dart/app_colors.dart';
// import 'package:convo/features/chat/presentation/bloc/chat_bloc/chat_bloc.dart';

// class ChatPage extends StatefulWidget {
//   final UserModel user;
//   const ChatPage({super.key, required this.user});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   late final TextEditingController _messageController;

//   final FocusNode _focusNode = FocusNode();
//   bool emoji = false;
//   bool mssgSelected = false;
//   Set<String> mssgIdSelected = {};
//   Set<String> mssgCopySelected = {};
//   bool mssgEdit = false;
//   String? editingMessageId;
//   bool isReplying = false;
//   String? replyMessage;
//   int? replyMessageId;

//   @override
//   void initState() {
//     super.initState();
//     _messageController = TextEditingController();
//     context.read<ChatBloc>().add(
//       ChatEvent.getMssg(receiverId: widget.user.id.toString()),
//     );

//     Future.delayed(Duration(milliseconds: 300), () {
//       _focusNode.requestFocus();
//     });
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }

//   void _handleReply(msg) {
//     setState(() {
//       isReplying = true;
//       replyMessage = msg.message;
//       replyMessageId = msg.id;
//     });

//     FocusScope.of(context).unfocus();

//     Future.delayed(const Duration(milliseconds: 50), () {
//       if (mounted) {
//         FocusScope.of(context).requestFocus(_focusNode);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ChatBloc, ChatState>(
//       builder: (context, state) {
//         return WillPopScope(
//           onWillPop: () async {
//             Navigator.popUntil(context, (route) => route.isFirst);
//             return false; // prevent default back
//           },
//           child: Scaffold(
//             backgroundColor: AppColors.backgroundColor(context),

//             /// APP BAR
//             appBar: ChatAppbarWidget(
//               mssgSelected: mssgSelected,
//               mssgIdSelected: mssgIdSelected,
//               mssgCopySelected: mssgCopySelected,
//               user: widget.user,
//               state: state,

//               onBack: () {
//                 if (mssgSelected) {
//                   setState(() {
//                     mssgSelected = false;
//                     mssgIdSelected.clear();
//                   });
//                 } else {
//                   Navigator.pop(context);
//                 }
//               },

//               onClearSelection: () {
//                 setState(() {
//                   mssgSelected = false;
//                   mssgCopySelected.clear();
//                   mssgIdSelected.clear();
//                 });
//               },

// onEdit: (id, message) {
//   setState(() {
//     mssgEdit = true;
//     editingMessageId = id;
//   });

//   // Pass the message to input field automatically via the controller
//   _messageController.text = message;

//   // Focus text field so user can edit immediately
//   Future.delayed(const Duration(milliseconds: 50), () {
//     _focusNode.requestFocus();
//   });
// },

//               onDelete: () {
//                 for (final id in mssgIdSelected) {
//                   context.read<ChatBloc>().add(
//                     ChatEvent.deletMssg(mssId: int.parse(id)),
//                   );
//                 }

//                 setState(() {
//                   mssgSelected = false;
//                   mssgIdSelected.clear();
//                 });
//               },

//               onVoiceCall: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => VoiceCallPage(user: widget.user),
//                   ),
//                 );
//               },

//               onVideoCall: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => VideoCallPage(user: widget.user),
//                   ),
//                 );
//               },
//             ),

//             /// BODY
//             body: Container(
//               height: double.infinity,
//               // Background Wallpaper
//               decoration: BoxDecoration(
//                 image: isDeviceThemeDark(context)
//                     ? DecorationImage(
//                         image: AssetImage("assests/wallpapers/wallpaper2.jpg"),
//                         fit: BoxFit.cover,
//                         alignment: Alignment.topCenter,
//                       )
//                     : DecorationImage(
//                         image: AssetImage("assests/wallpapers/LightThem.png"),
//                         fit: BoxFit.fitWidth,
//                       ),
//               ),

//               child: Column(
//                 children: [
//                   // Massegs
//                   Expanded(
//                     child: BlocBuilder<LoginBloc, LoginState>(
//                       builder: (context, sstate) {
//                         final profile = context.read<LoginBloc>().state.profile;

//                         return ChatMessageList(
//                           messages: state.messages,
//                           profileId: profile?.id.toString(),
//                           mssgSelected: mssgSelected,
//                           mssgIdSelected: mssgIdSelected,
//                           mssgCopySelected: mssgCopySelected,

//                           onReply: (msg) {
//                             _handleReply(msg);
//                           },

//                           onLongPress: (msg) {
//                             setState(() {
//                               mssgSelected = true;
//                               mssgIdSelected.add(msg.id.toString());
//                               mssgCopySelected.add(msg.message.toString());
//                             });
//                           },

//                           onTapSelect: (msg) {
//                             if (mssgSelected) {
//                               setState(() {
//                                 final id = msg.id.toString();

//                                 if (mssgIdSelected.contains(id)) {
//                                   mssgIdSelected.remove(id);

//                                   if (mssgIdSelected.isEmpty) {
//                                     mssgSelected = false;
//                                   }
//                                 } else {
//                                   mssgIdSelected.add(id);
//                                   mssgCopySelected.add(id);
//                                 }
//                               });
//                             }
//                           },
//                         );
//                       },
//                     ),
//                   ),

//                   ///Reply INPUT BAR
//                   if (isReplying)
//                     ReplyPreviewWidget(
//                       replyMessage: replyMessage,
//                       onCancel: () {
//                         setState(() {
//                           isReplying = false;
//                           replyMessage = null;
//                           replyMessageId = null;
//                         });

//                         FocusScope.of(context).unfocus();

//                         Future.delayed(const Duration(milliseconds: 50), () {
//                           FocusScope.of(context).requestFocus(_focusNode);
//                         });
//                       },
//                     ),
//                   // INPUT BAR
//                   ChatInputFieldWidget(
//                     receiverId: widget.user.id.toString(),
//                     isEditing: mssgEdit,
//                     editingMessageId: editingMessageId,
//                     replyMessageId: replyMessageId,
//                     onCancelEdit: () {
//                       setState(() {
//                         mssgEdit = false;
//                         editingMessageId = null;
//                       });
//                     },
//                     onSendSuccess: () {
//                       setState(() {
//                         isReplying = false;
//                       });
//                     },
//                   ),
//                   // Emoji picker
//                   EmojiPickerWidget(
//                     isVisible: emoji,
//                     controller: _messageController,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }



import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/const.dart/slide_page_route.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/chat/presentation/pages/contact_user_profile_page.dart';
import 'package:convo/features/chat/presentation/pages/video_call_page.dart';
import 'package:convo/features/chat/presentation/pages/voice_call_page.dart';
import 'package:convo/features/chat/presentation/widgets/mssg_widgets.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/features/chat/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:lottie/lottie.dart';
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
            appBar: AppBar(
              toolbarHeight: 70,
              backgroundColor: AppColors.chatProfileColor(context),
              titleSpacing: 0,
              leading: IconButton(
                icon: Icon(
                  mssgSelected ? Icons.close : Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => mssgSelected
                    ? setState(() {
                        _focusNode.unfocus();
                        mssgSelected = false;
                        mssgIdSelected.clear();
                      })
                    : Navigator.pop(context),
              ),
              title: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: ContactUserProfilePage(user: widget.user),
                      beginOffset: const Offset(-1, 0), // Slide from left
                    ),
                  );
                },

                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primary,
                  child: ClipOval(
                    child: Lottie.asset(widget.user.lotti, fit: BoxFit.cover),
                  ),
                ),
                title: Text(
                  widget.user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  widget.user.online ? "online" : "offline",
                  style: TextStyle(
                    color: widget.user.online
                        ? isDeviceThemeDark(context)
                              ? Colors.green
                              : Colors.white
                        : Colors.white,
                  ),
                ),
              ),
              actions: mssgSelected
                  ? [
                      if (mssgIdSelected.length == 1)
                        if (mssgIdSelected.length == 1)
                          Builder(
                            builder: (_) {
                              final profile = context
                                  .read<LoginBloc>()
                                  .state
                                  .profile;
                              final selectedMsg = state.messages.firstWhere(
                                (e) => e.id.toString() == mssgIdSelected.first,
                              );

                              if (selectedMsg.senderId.toString() !=
                                  profile?.id.toString()) {
                                return const SizedBox();
                              }

                              return IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _messageController.text = selectedMsg.message;

                                  setState(() {
                                    mssgEdit = true;
                                    editingMessageId = mssgIdSelected.first;
                                    mssgSelected = false;
                                    mssgIdSelected.clear();
                                  });
                                },
                              );
                            },
                          ),

                      IconButton(
                        icon: Icon(Icons.copy, color: Colors.white),
                        onPressed: () async {
                          if (mssgCopySelected.isEmpty) return;

                          final copyText = mssgCopySelected.join("\n");

                          await Clipboard.setData(
                            ClipboardData(text: copyText),
                          );

                          Fluttertoast.showToast(
                            msg: "Text Copied",
                            gravity: ToastGravity.CENTER,
                          );

                          setState(() {
                            mssgSelected = false;
                            mssgCopySelected.clear();
                          });
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
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
                      ),
                    ]
                  : [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VoiceCallPage(user: widget.user),
                            ),
                          );
                        },
                        icon: Icon(Icons.call, color: Colors.white, size: 28),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.scale,
                              alignment: Alignment.bottomCenter,
                              child: VideoCallPage(user: widget.user),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
            ),

            /// BODY
            body: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                image: isDeviceThemeDark(context)
                    ? DecorationImage(
                        image: AssetImage("assests/wallpapers/wallpaper2.jpg"),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      )
                    : DecorationImage(
                        image: AssetImage("assests/wallpapers/LightThem.png"),
                        fit: BoxFit.fitWidth,
                      ),
              ),

              child: Column(
                children: [
                  Expanded(
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, sstate) {
                        final profile = context.read<LoginBloc>().state.profile;
                        return state.messages.isEmpty
                            ? SizedBox()
                            : ListView.builder(
                                reverse: true,
                                itemCount: state.messages.length,
                                itemBuilder: (context, index) {
                                  final msg =
                                      state.messages[state.messages.length -
                                          index -
                                          1];

                                  final bool isMe =
                                      msg.senderId.toString() ==
                                      profile?.id.toString();

                                  return Dismissible(
                                    key: Key(msg.id.toString()),
                                    direction: DismissDirection.startToEnd,
                                    confirmDismiss: (_) async {
                                      _handleReply(msg);
                                      return false;
                                    },

                                    background: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 20),
                                      child: const Icon(
                                        Icons.reply,
                                        color: Colors.blue,
                                      ),
                                    ),

                                    child: GestureDetector(
                                      onLongPress: () {
                                        setState(() {
                                          mssgSelected = true;
                                          mssgIdSelected.add(msg.id.toString());
                                          mssgCopySelected.add(
                                            msg.message.toString(),
                                          );
                                        });
                                      },
                                      onTap: () {
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
                                              mssgCopySelected.add(id);
                                            }
                                          });
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          if (mssgSelected)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              child: Icon(
                                                mssgIdSelected.contains(
                                                      msg.id.toString(),
                                                    )
                                                    ? Icons.check_circle
                                                    : Icons
                                                          .radio_button_unchecked,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          Expanded(
                                            child: MssgWidgets(
                                              chatStatus: msg.id == 0
                                                  ? ChatStatus.sending
                                                  : ChatStatus.send,
                                              isMe: isMe,
                                              message: msg.message,
                                              replyMessage: msg.reply?.message,
                                              time: msg.createdAt,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                      },
                    ),
                  ),

                  ///Reply INPUT BAR
                  if (isReplying)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey.shade200,
                      child: Row(
                        children: [
                          Container(width: 4, height: 40, color: Colors.blue),
                          const SizedBox(width: 8),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Replying to",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  replyMessage ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                isReplying = false;
                                replyMessage = null;
                                replyMessageId = null;
                              });
                              FocusScope.of(context).unfocus();
                              Future.delayed(Duration(milliseconds: 50), () {
                                FocusScope.of(context).requestFocus(_focusNode);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  // INPUT BAR
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chatProfileColor(context),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// Emoji Button
                        IconButton(
                          iconSize: 30,
                          color: AppColors.sendBT(context),
                          icon: Icon(
                            emoji
                                ? Icons.keyboard
                                : Icons.emoji_emotions_outlined,
                          ),
                          onPressed: () {
                            setState(() => emoji = !emoji);

                            if (emoji) {
                              _focusNode.unfocus(); // hide keyboard
                            } else {
                              _focusNode.requestFocus(); // show keyboard
                            }
                          },
                        ),

                        /// Text Field
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            minLines: 1,
                            maxLines: 4,
                            onTap: () {
                              setState(() => emoji = false);
                            },
                            onChanged: (v) {
                              if (mssgEdit && v.trim().isEmpty) {
                                setState(() {
                                  mssgEdit = false;
                                  editingMessageId = null;
                                });
                              } else {
                                setState(() {
                                  // emoji=false;
                                });
                              }
                            },
                            style: TextStyle(
                             
                              color: AppColors.iconColor,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              filled: true,
                              fillColor: AppColors.backgroundColor(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: _messageController.text.isEmpty
                              ? IconButton(
                                  iconSize: 30,
                                  color: AppColors.sendBT(context),
                                  onPressed: () {},
                                  icon: const Icon(Icons.mic, size: 28),
                                )
                              : mssgEdit
                              ? IconButton(
                                  iconSize: 30,
                                  color: AppColors.sendBT(context),
                                  onPressed: () {
                                    if (editingMessageId == null) return;

                                    context.read<ChatBloc>().add(
                                      ChatEvent.editMssg(
                                        mssgId: int.parse(editingMessageId!),
                                        newMssg: _messageController.text.trim(),
                                      ),
                                    );

                                    _messageController.clear(); // 🔥 move here

                                    setState(() {
                                      mssgEdit = false;
                                      editingMessageId = null;
                                    });
                                  },
                                  icon: const Icon(Icons.check, size: 28),
                                )
                              : IconButton(
                                  iconSize: 30,
                                  color: AppColors.sendBT(context),
                                  onPressed: () {
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
                                  icon: const Icon(Icons.send, size: 28),
                                ),
                        ),
                      ],
                    ),
                  ),

                  if (emoji && MediaQuery.of(context).viewInsets.bottom == 0)
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 50),
                      offset: emoji ? Offset.zero : const Offset(0, 1),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: EmojiPicker(
                          textEditingController: _messageController,
                          config: const Config(
                            categoryViewConfig: CategoryViewConfig(
                              initCategory: Category.SMILEYS,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
