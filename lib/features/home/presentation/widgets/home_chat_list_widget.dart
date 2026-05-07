import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/custom/custom_text.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/auth/presentation/widgets/full_image_screen_page.dart';
import 'package:convo/features/chat/presentation/pages/chat_page.dart';
import 'package:convo/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomeChatListWidget extends StatefulWidget {
  final Set<int> selectedChats;
  final Function(int) onSelect;
  final bool selectionMode;

  const HomeChatListWidget({
    super.key,
    required this.selectedChats,
    required this.onSelect,
    required this.selectionMode,
  });

  @override
  State<HomeChatListWidget> createState() => _HomeChatListWidgetState();
}

class _HomeChatListWidgetState extends State<HomeChatListWidget> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeEvent.init());
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    if (diff == 0) {
      return DateFormat('hh:mm a').format(date);
    }
    if (diff == 1) {
      return "Yesterday";
    }
    return DateFormat('dd MMM').format(date);
  }

  void _openChat(dynamic user) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChatPage(user: user),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    ).then((_) {
      context.read<HomeBloc>().add(const HomeEvent.init());
    });
  }

  void _showProfileDialog(BuildContext context, dynamic user) {
    final imageUrl = "${ApiConfig.baseUrl}/uploads/${user.profile}";
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 35),
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border.all(width: 4, color: AppColors.primary),
              color: const Color.fromARGB(255, 222, 204, 204),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// IMAGE
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImagePage(image: imageUrl),
                      ),
                    );
                  },
                  child: Hero(
                    tag: imageUrl,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(26),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            height: 300,
                            color: Colors.grey.shade900,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 80,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                /// ACTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dialogButton(
                        icon: Icons.call_rounded,
                        color: Colors.green,
                        onTap: () {},
                      ),
                      _dialogButton(
                        icon: Icons.chat_rounded,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          _openChat(user);
                        },
                      ),
                      _dialogButton(
                        icon: Icons.videocam_rounded,
                        color: Colors.purple,
                        onTap: () {},
                      ),
                      _dialogButton(
                        icon: Icons.info_outline_rounded,
                        color: Colors.orange,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<LoginBloc>().state.profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        if (state.homeChatsStatus == Status.error ||
            state.homePageChats.isEmpty) {
          return Center(
            child: Text(
              "No Chats Yet",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: state.homePageChats.length,

          itemBuilder: (_, i) {
            final chat = state.homePageChats[i];
            final isMe = profile.id == chat.sender.id;
            final user = isMe ? chat.receiver : chat.sender;
            final selected = widget.selectedChats.contains(chat.id);
            final hasProfile =
            user.profile.isNotEmpty && user.profile.toString().isNotEmpty;

            final showUnread = !isMe && chat.unSeenCount > 0;

            return GestureDetector(
              onTap: () {
                if (widget.selectionMode) {
                  widget.onSelect(chat.id);
                } else {
                  _openChat(user);
                }
              },

              onLongPress: () {
                widget.onSelect(chat.id);
              },

              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),

                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),

                  color: selected
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.transparent,
                ),

                child: Row(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showProfileDialog(context, user);
                          },

                          child: Hero(
                            tag: NetworkImage(
                              "${ApiConfig.baseUrl}/uploads/${user.profile}",
                            ),

                            child: Container(
                              padding: const EdgeInsets.all(2),

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xff4F46E5),
                                    Color(0xff7C3AED),
                                  ],
                                ),
                              ),

                              child: CircleAvatar(
                                radius: 31,

                                backgroundColor: Colors.grey.shade200,

                                backgroundImage: hasProfile
                                    ? NetworkImage(
                                        "${ApiConfig.baseUrl}/uploads/${user.profile}",
                                      )
                                    : null,

                                child: !hasProfile
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),

                        /// ONLINE DOT
                        Positioned(
                          right: 2,
                          bottom: 2,

                          child: Container(
                            height: 15,
                            width: 15,

                            decoration: BoxDecoration(
                              color: user.online ? Colors.green : Colors.grey,

                              shape: BoxShape.circle,

                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),

                        /// SELECTED
                        if (selected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.35),

                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            user.name.toString().trim().isEmpty
                                ? user.phone.toString()
                                : user.name.toString(),

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.iconColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            showUnread
                                ? "${chat.unSeenCount} new message${chat.unSeenCount > 1 ? "'s" : ''}"
                                : chat.message.toString(),

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.iconColor,

                              fontWeight: showUnread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        if (showUnread)
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),

                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),

                            decoration: BoxDecoration(
                              color: AppColors.primary,

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              chat.unSeenCount.toString(),

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        CustomText(
                          text: _formatDate(chat.createdAt),

                          bold: FontWeight.w500,
                          size: 11,

                          clr: showUnread ? AppColors.iconColor : Colors.grey,
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
    );
  }

  Widget _dialogButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
