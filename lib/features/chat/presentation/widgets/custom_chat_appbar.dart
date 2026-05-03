import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/chat/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:convo/features/chat/presentation/widgets/guesture_dector_more_vert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class CustomChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel user;
  final bool mssgSelected;
  final Set<String> mssgIdSelected;
  final Set<String> mssgCopySelected;
  final ChatState state;
  final VoidCallback onBackPressed;
  final VoidCallback onProfileTap;
  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;
  final VoidCallback onCopyMessages;
  final VoidCallback onDeleteMessages;
  final Function(String) onEditMessage;

  const CustomChatAppBar({
    Key? key,
    required this.user,
    required this.mssgSelected,
    required this.mssgIdSelected,
    required this.mssgCopySelected,
    required this.state,
    required this.onBackPressed,
    required this.onProfileTap,
    required this.onVoiceCall,
    required this.onVideoCall,
    required this.onCopyMessages,
    required this.onDeleteMessages,
    required this.onEditMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: AppColors.chatProfileColor(context),
      titleSpacing: 0,
      leading: _buildLeadingButton(context),
      title: _buildTitleTile(context), // ✅ Pass context
      actions: mssgSelected ? _buildSelectedActions(context) : _buildDefaultActions(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);

  Widget _buildLeadingButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        mssgSelected ? Icons.close : Icons.arrow_back,
        color: Colors.white,
      ),
      onPressed: onBackPressed,
    );
  }

  Widget _buildTitleTile(BuildContext context) { // ✅ Added context parameter
    return ListTile(
      onTap: onProfileTap,
      contentPadding: EdgeInsets.zero,
      leading: _buildProfileAvatar(),
      title: _buildNicknameText(),
      subtitle: _buildOnlineStatusText(context), // ✅ Pass context
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 25,
      backgroundColor: AppColors.primary,
      backgroundImage: NetworkImage("${ApiConfig.baseUrl}/uploads/${user.profile}"),
    );
  }

  Widget _buildNicknameText() {
    return Text(
      user.name,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildOnlineStatusText(BuildContext context) { // ✅ Added context parameter
    return Text(
      user.online ? "online" : "offline",
      style: TextStyle(
        color: user.online
            ? isDeviceThemeDark(context) // ✅ Now context is available
                ? Colors.green
                : Colors.white
            : Colors.white,
      ),
    );
  }

  List<Widget> _buildSelectedActions(BuildContext context) {
    return [
      if (mssgIdSelected.length == 1) _buildEditButton(context),
      _buildCopyButton(),
      _buildDeleteButton(),
    ];
  }

  Widget _buildEditButton(BuildContext context) {
    return Builder(
      builder: (_) {
        final profile = context.read<LoginBloc>().state.profile;
        final messageId = mssgIdSelected.first;
        final selectedMsg = state.messages.firstWhere(
          (e) => e.id.toString() == messageId,
        );

        if (selectedMsg.senderId.toString() != profile?.id.toString()) {
          return const SizedBox();
        }

        return IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => onEditMessage(messageId),
        );
      },
    );
  }

  Widget _buildCopyButton() {
    return IconButton(
      icon: const Icon(Icons.copy, color: Colors.white),
      onPressed: onCopyMessages,
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.white),
      onPressed: onDeleteMessages,
    );
  }

  List<Widget> _buildDefaultActions() {
    return [
      IconButton(
        onPressed: onVoiceCall,
        icon: const Icon(Icons.call, color: Colors.white, size: 28),
      ),
      IconButton(
        onPressed: onVideoCall,
        icon: const Icon(Icons.videocam, color: Colors.white, size: 28),
      ),
      const GestureDetectorMoreVert(),
      const SizedBox(width: 8),
    ];
  }
}
