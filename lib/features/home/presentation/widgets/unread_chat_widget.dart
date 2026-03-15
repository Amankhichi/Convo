import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/custom/custom_text.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/chat/presentation/pages/chat_page.dart';
import 'package:convo/features/chat/presentation/pages/contact_user_profile_page.dart';
import 'package:convo/features/chat/presentation/pages/video_call_page.dart';
import 'package:convo/features/chat/presentation/pages/voice_call_page.dart';
import 'package:convo/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class UnreadChatWidget extends StatelessWidget {
  const UnreadChatWidget({super.key});


  @override
  Widget build(BuildContext context) {
    final profile = context.watch<LoginBloc>().state.profile!;

      String _formatDate(DateTime dateTime) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return DateFormat('hh:mm a').format(dateTime);
    } else if (difference == 1) {
      return "Yesterday";
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }


    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {

        if (state.homeChatsStatus == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.homeChatsStatus == Status.error) {
          return const Center(child: Text("No Chats"));
        }

        /// 🔥 filter only unseen chats
        final unreadChats = state.homePageChats
            .where((chat) => chat.unSeencount > 0)
            .toList();

        if (unreadChats.isEmpty) {
          return const Center(child: Text("No unread chats"));
        }

        return Column(
          children: unreadChats.map((chat) 
           {
            final bool isMe = profile.id == chat.senderId;
            final user = isMe ? chat.receiver : chat.sender;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ChatPage(user: user),
                    transitionsBuilder: (_, animation, __, child) {
                      return SlideTransition(
                        position: Tween(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                ).then((_) {
                  context.read<HomeBloc>().add(const HomeEvent.init());
                });
              },

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    /// Avatar (dialog unchanged)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Dialog(
                                alignment: Alignment.topCenter,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 250,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(15),
                                            ),
                                        child: Container(
                                          color: AppColors.primary,
                                          child: Lottie.asset(
                                            user.lotti,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// same dialog buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.call,
                                            size: 28,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    VoiceCallPage(user: user),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.videocam,
                                            size: 28,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    VideoCallPage(user: user),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.message,
                                            size: 28,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ChatPage(user: user),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.info,
                                            size: 28,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ContactUserProfilePage(
                                                      user: user,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 35,
                        child: ClipOval(child: Lottie.asset(user.lotti)),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Name + Message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name.isEmpty ? user.phone : user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.iconColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (chat.unSeencount) > 1
                                ? "new messages"
                                : chat.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.iconColor,
                              fontWeight: (chat.unSeencount) > 0
                                  ? FontWeight.w800
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Time + unread badge
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if ((chat.unSeencount ) > 0)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              chat.unSeencount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        CustomText(
                          text: _formatDate(chat.createdAt),
                          bold: FontWeight.w500,
                          size: 12,
                          clr: (chat.unSeencount) > 0
                              ? AppColors.iconColor
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        
        );
      },
    );
  }
}