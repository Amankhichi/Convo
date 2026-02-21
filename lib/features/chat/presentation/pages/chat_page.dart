import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/chat/presentation/pages/contact_user_profile_page.dart';
import 'package:convo/features/chat/presentation/widgets/mssg_widgets.dart';
import 'package:convo/features/home/presentation/bloc/singup_bloc/singup_bloc.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/features/chat/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  String? replyMessageId;

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
              backgroundColor: AppColors.ChatprofileColor(context),
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
                    : Navigator.popUntil(context, (route) => route.isFirst),
              ),
              title: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          ContactUserProfilePage(user: widget.user),
                      transitionsBuilder: (_, a, __, c) => SlideTransition(
                        position: Tween(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        ).animate(a),
                        child: c,
                      ),
                    ),
                  );
    //                   if(state.GetMssgStatus==Status.error){
    //   showError(context, "mssg not get");
    // }else{
    //   showSuccess(context, "mssg is get it");
    // }
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
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            final id = mssgIdSelected.first;
                            final msg = state.messages.firstWhere(
                              (e) => e.id.toString() == id,
                            );

                            _messageController.text = msg.message;

                            setState(() {
                              mssgEdit = true;
                              editingMessageId = id;
                              mssgSelected = false;
                              mssgIdSelected.clear();
                            });
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
                        onPressed: () {},
                        icon: Icon(Icons.call, color: Colors.white, size: 28),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
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
                    child: BlocBuilder<SingupBloc, SingupState>(
                      builder: (context, sstate) {
                        final profile = context
                            .read<SingupBloc>()
                            .state
                            .profile;
                        return state.GetMssgStatus == Status.loading
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                reverse: true,
                                itemCount: state.messages.length,
                                itemBuilder: (context, index) {
                                  final msg = state.messages[state.messages.length -index -1];

                                  final bool isMe =
                                      msg.senderId == profile?.id.toString();

                                  return Dismissible(
                                    key: Key(msg.id.toString()),
                                    direction: DismissDirection.startToEnd,
                                    confirmDismiss: (_) async {
                                      setState(() {
                                        isReplying = true;
                                        replyMessage = msg.message;
                                        replyMessageId = msg.id.toString();
                                        _focusNode.requestFocus();
                                      });
                                      // WidgetsBinding.instance
                                      //     .addPostFrameCallback((_) {
                                            _focusNode.requestFocus();
                                          // });
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
                                              isMe: isMe,
                                              message: msg.message,
                                              replyMessage: msg.reply,
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
                      color: AppColors.ChatprofileColor(context),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// Emoji Button
                        IconButton(
                          iconSize: 30,
                          color: AppColors.background(context),
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
                              color: AppColors.invertTextColor(context),
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

                        /// Mic / Send / Edit Button
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: _messageController.text.isEmpty
                              ? IconButton(
                                  iconSize: 30,
                                  color: AppColors.background(context),
                                  onPressed: () {},
                                  icon: const Icon(Icons.mic, size: 28),
                                )
                              : mssgEdit
                              ? IconButton(
                                  iconSize: 30,
                                  color: AppColors.background(context),
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
                                  color: AppColors.background(context),
                                  onPressed: () {
                                    context.read<ChatBloc>().add(
                                      ChatEvent.sendMssg(
                                        mssg: _messageController.text.trim(),
                                        receiverId: widget.user.id.toString(),
                                        reply: replyMessage.toString(),
                                      ),
                                    );
                                        isReplying=false;
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
