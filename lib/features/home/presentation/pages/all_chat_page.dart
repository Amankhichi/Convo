
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/chat/presentation/pages/chat_page.dart';
import 'package:convo/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:convo/features/home/presentation/widgets/common_chat_list_UI_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllChatPage extends StatefulWidget {
  final Set<int> selectedChats;
  final Function(int) onSelect;
  final bool selectionMode;

  const AllChatPage({
    super.key,
    required this.selectedChats,
    required this.onSelect,
    required this.selectionMode,
  });

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeEvent.init());
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
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  return BlocBuilder<HomeBloc, HomeState>(
    builder: (_, state) {
      if (state.homeChatsStatus == Status.error ||
          state.homePageChats.isEmpty) {
        return Center(
          child: Text(
            "No Chats Yet",
            style: TextStyle(
              color: AppColors.iconColor,
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

          final user = isMe
              ? chat.receiver
              : chat.sender;

          final selected =
              widget.selectedChats.contains(chat.id);

          final showUnread =
              !isMe && chat.unSeenCount > 0;

          return CommonChatListUiWidgets(
            chat: chat,
            user: user,

            selected: selected,
            showUnread: showUnread,

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
          );
        },
      );
    },
  );
}
}
