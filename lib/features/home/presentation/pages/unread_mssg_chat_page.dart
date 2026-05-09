import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/chat/presentation/pages/chat_page.dart';
import 'package:convo/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:convo/features/home/presentation/widgets/common_chat_list_UI_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnreadMssgChatPage extends StatelessWidget {
  const UnreadMssgChatPage({super.key});


@override
Widget build(BuildContext context) {
  final profile = context.watch<LoginBloc>().state.profile!;

  return BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) {

      if (state.homeChatsStatus == Status.error) {
        return Center(
          child: Text(
            "No Chats",
            style: TextStyle(color: AppColors.iconColor),
          ),
        );
      }

      final unreadChats = state.homePageChats
          .where((chat) => chat.unSeenCount > 0)
          .toList();

      if (unreadChats.isEmpty) {
        return const Center(
          child: Text("No unread chats"),
        );
      }

      return Column(
        children: unreadChats.map((chat) {

          final isMe = profile.id == chat.sender.id;

          final user = isMe
              ? chat.receiver
              : chat.sender;

          return CommonChatListUiWidgets(
            chat: chat,
            user: user,

            selected: false,

            showUnread: true,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(user: user),
                ),
              );
            },

            onLongPress: () {
            },

          );

        }).toList(),
      );
    },
  );
}
}

