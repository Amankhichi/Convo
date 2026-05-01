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

    if (diff == 0) return DateFormat('hh:mm a').format(date);
    if (diff == 1) return "Yesterday";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _openChat(user) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChatPage(user: user),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
    ).then((_) {
      context.read<HomeBloc>().add(const HomeEvent.init());
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<LoginBloc>().state.profile!;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        if (state.homeChatsStatus == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.homeChatsStatus == Status.error) {
          return Center(
            child: Text(
              "No Chats Yet",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          );
        }

        return ListView.builder(
          itemCount: state.homePageChats.length,
          itemBuilder: (_, i) {
            final chat = state.homePageChats[i];
            final isMe = profile.id == chat.sender;
            final user = isMe ? chat.receiver : chat.sender;
            final selected = widget.selectedChats.contains(chat.id);

            return GestureDetector(
              onTap: () => widget.selectionMode
                  ? widget.onSelect(chat.id)
                  : _openChat(user),
              onLongPress: () => widget.onSelect(chat.id),

              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: selected
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.transparent,
                ),

                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.primary,
                          backgroundImage: NetworkImage(
                            "${ApiConfig.baseUrl}/uploads/${user.profile}",
                          ),
                        ),

                        if (selected)
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                                weight: 900,
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
                            user.name.isEmpty ? user.phone : user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.iconColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            chat.unSeenCount > 1
                                ? "new messages"
                                : chat.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.iconColor,
                              fontWeight: chat.unSeenCount > 0
                                  ? FontWeight.w800
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      children: [
                        if (chat.unSeenCount > 0)
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
                              chat.unSeenCount.toString(),
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
