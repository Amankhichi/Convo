import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:flutter/material.dart';

class ContactUserProfilePage extends StatefulWidget {
  const ContactUserProfilePage({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<ContactUserProfilePage> createState() =>
      _ContactUserProfilePageState();
}

class _ContactUserProfilePageState
    extends State<ContactUserProfilePage> {
  bool isBlocked = false;

  @override
  Widget build(BuildContext context) {
    final hasProfile =
        widget.user.profile != null &&
        widget.user.profile.toString().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// APP BAR
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.appBarColor(context),
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  /// TOP BACKGROUND
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),

                  /// DARK OVERLAY
                  Container(
                    color: Colors.black.withOpacity(0.25),
                  ),

                  /// PROFILE CONTENT
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        /// PROFILE IMAGE
                        Hero(
                          tag: widget.user.id,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white24,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withOpacity(0.4),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor: Colors.white12,
                              backgroundImage: hasProfile
                                  ? NetworkImage(
                                      "${ApiConfig.baseUrl}/uploads/${widget.user.profile}",
                                    )
                                  : null,
                              child: !hasProfile
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// NAME
                        Text(
                          widget.user.name.toString().trim().isEmpty
                              ? widget.user.phone.toString()
                              : widget.user.name.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// NICKNAME
                        if (widget.user.nickname
                            .toString()
                            .trim()
                            .isNotEmpty)
                          Text(
                            "@${widget.user.nickname}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        const SizedBox(height: 12),

                        /// ONLINE STATUS
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.user.online
                                ? Colors.green.withOpacity(0.2)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: widget.user.online
                                  ? Colors.green
                                  : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: widget.user.online
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.user.online
                                    ? "Online"
                                    : "Offline",
                                style: TextStyle(
                                  color: widget.user.online
                                      ? Colors.greenAccent
                                      : Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BODY
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Column(
                children: [
                  /// ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          context,
                          icon: Icons.call_rounded,
                          title: "Call",
                          onTap: () {},
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _actionButton(
                          context,
                          icon: Icons.videocam_rounded,
                          title: "Video",
                          onTap: () {},
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _actionButton(
                          context,
                          icon: Icons.chat_bubble_rounded,
                          title: "Message",
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  /// ABOUT CARD
                  _infoCard(
                    context,
                    title: "About",
                    icon: Icons.info_outline_rounded,
                    child: Text(
                      widget.user.about
                              .toString()
                              .trim()
                              .isEmpty
                          ? "Hey there! I am using Convo."
                          : widget.user.about.toString(),
                      style: TextStyle(
                        color: AppColors.textColor(context),
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// PHONE CARD
                  _infoCard(
                    context,
                    title: "Phone Number",
                    icon: Icons.phone_outlined,
                    child: Text(
                      widget.user.phone.toString(),
                      style: TextStyle(
                        color: AppColors.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// MEDIA CARD
                  _infoCard(
                    context,
                    title: "Media, Links & Docs",
                    icon: Icons.perm_media_outlined,
                    child: Row(
                      children: [
                        _mediaBox(Icons.image_rounded),
                        const SizedBox(width: 10),
                        _mediaBox(Icons.link_rounded),
                        const SizedBox(width: 10),
                        _mediaBox(Icons.insert_drive_file_rounded),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BLOCK BUTTON
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.appBarColor(context),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isBlocked = !isBlocked;
                        });
                      },
                      icon: Icon(
                        isBlocked
                            ? Icons.lock_open_rounded
                            : Icons.block_rounded,
                        color: isBlocked
                            ? Colors.green
                            : Colors.red,
                      ),
                      label: Text(
                        isBlocked
                            ? "Unblock Contact"
                            : "Block Contact",
                        style: TextStyle(
                          color: isBlocked
                              ? Colors.green
                              : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.appBarColor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.appBarColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _mediaBox(IconData icon) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
