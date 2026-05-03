import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/custom/custom_text.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<LoginBloc>().state.profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        if (state.homeChatsStatus == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

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

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: state.homePageChats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (_, i) {
            final chat = state.homePageChats[i];
            final isMe = profile.id == chat.sender.id;

            final user = isMe ? chat.receiver : chat.sender;

            final selected = widget.selectedChats.contains(chat.id);

            final hasProfile =
                user.profile.isNotEmpty && user.profile.toString().isNotEmpty;

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
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary.withOpacity(0.2),

                          backgroundImage: hasProfile
                              ? NetworkImage(
                                  "${ApiConfig.baseUrl}/uploads/${user.profile}",
                                )
                              : null,

                          child: !hasProfile
                              ? Icon(Icons.person, color: AppColors.primary)
                              : null,
                        ),

                        if (selected)
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.check,
                                size: 16,
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
                            chat.unSeenCount > 0
                                ? "${chat.unSeenCount} new message${chat.unSeenCount > 1 ? 's' : ''}"
                                : chat.message.toString(),

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.iconColor,
                              fontWeight: chat.unSeenCount > 0
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
                        if (chat.unSeenCount > 0)
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
                          clr: chat.unSeenCount > 0
                              ? AppColors.iconColor
                              : Colors.grey,
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
}
