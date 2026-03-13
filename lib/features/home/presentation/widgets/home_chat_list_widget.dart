import 'dart:async';

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

class HomeChatListWidget extends StatefulWidget {
  const HomeChatListWidget({super.key});

  @override
  State<HomeChatListWidget> createState() => _HomeChatListWidgetState();
}

class _HomeChatListWidgetState extends State<HomeChatListWidget> {

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeEvent.init());
  }

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

  @override
  Widget build(BuildContext context) {

    final profile = context.watch<LoginBloc>().state.profile!;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {

        if (state.homeChatsStatus == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.homeChatsStatus == Status.error) {
          return Center(
            child: Text(
              "No Chats Yet",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }

        return Column(
          children: state.homePageChats.map((chat){
            final bool isMe = profile.id == chat.senderId;
            final user = isMe ? chat.receiver : chat.sender;
            return ListTile(
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

              leading: GestureDetector(
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

                              /// Profile Animation
                              SizedBox(
                                height: 250,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
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

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [

                                  /// Voice Call
                                  IconButton(
                                    icon: const Icon(Icons.call, size: 28),
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

                                  /// Video Call
                                  IconButton(
                                    icon: const Icon(Icons.videocam, size: 28),
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

                                  /// Chat
                                  IconButton(
                                    icon: const Icon(Icons.message, size: 28),
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

                                  /// Info
                                  IconButton(
                                    icon: const Icon(Icons.info, size: 28),
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
                  child: ClipOval(
                    child: Lottie.asset(user.lotti),
                  ),
                ),
              ),

              /// User Name
              title: Text(
                user.name.isEmpty?user.phone:user.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.iconColor,
                ),
              ),

              /// Last Message
              subtitle: Text(
                chat.message,
                style: TextStyle(
                  color:AppColors.iconColor,
                  fontWeight: isMe?FontWeight.w400:FontWeight.w800,
                ),
              ),

              /// Time
              trailing: CustomText(
                text: _formatDate(chat.createdAt),
                bold: FontWeight.w800,
                size: 12,
              ),
            );
          }).toList(),
        );

        return ListView.builder(
          itemCount: state.homePageChats.length,
          itemBuilder: (context, index) {
            final chat = state.homePageChats[index];
            final bool isMe = profile.id == chat.senderId;
            final user = isMe ? chat.receiver : chat.sender;

            return ListTile(
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

              leading: GestureDetector(
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

                              /// Profile Animation
                              SizedBox(
                                height: 250,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
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

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [

                                  /// Voice Call
                                  IconButton(
                                    icon: const Icon(Icons.call, size: 28),
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

                                  /// Video Call
                                  IconButton(
                                    icon: const Icon(Icons.videocam, size: 28),
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

                                  /// Chat
                                  IconButton(
                                    icon: const Icon(Icons.message, size: 28),
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

                                  /// Info
                                  IconButton(
                                    icon: const Icon(Icons.info, size: 28),
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
                  child: ClipOval(
                    child: Lottie.asset(user.lotti),
                  ),
                ),
              ),

              /// User Name
              title: Text(
                user.name.isEmpty?user.phone:user.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.iconColor,
                ),
              ),

              /// Last Message
              subtitle: Text(
                chat.message,
                style: TextStyle(
                  color:AppColors.iconColor,
                  fontWeight: isMe?FontWeight.w400:FontWeight.w800,
                ),
              ),

              /// Time
              trailing: CustomText(
                text: _formatDate(chat.createdAt),
                bold: FontWeight.w800,
                size: 12,
              ),
            );
          },
        );
      },
    );
  }
}