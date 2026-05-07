// import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/auth/presentation/widgets/full_image_screen_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final hasImage = state.lotti.isNotEmpty;

        return Scaffold(
          backgroundColor: const Color(0xff0F172A),

          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// APP BAR
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: const Color(0xff0F172A),
                elevation: 0,
                surfaceTintColor: Colors.transparent,

                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),

                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      /// TOP IMAGE
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xff4F46E5),
                              const Color(0xff7C3AED),
                              Colors.black.withOpacity(0.9),
                            ],
                          ),

                          image: hasImage
                              ? DecorationImage(
                                  image: NetworkImage(
                                    "${ApiConfig.baseUrl}/uploads/${state.lotti}",
                                  ),
                                  fit: BoxFit.cover,
                                  opacity: 0.35,
                                )
                              : null,
                        ),
                      ),

                      /// OVERLAY
                      Container(color: Colors.black.withOpacity(0.25)),

                      /// CONTENT
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30),

                            /// PROFILE IMAGE
/// PROFILE IMAGE
Hero(
  tag: "profile-image",

  child: GestureDetector(
    onTap: () {
      if (!hasImage) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImagePage(
            image:
                "${ApiConfig.baseUrl}/uploads/${state.lotti}",
          ),
        ),
      );
    },

    child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(5),

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            border: Border.all(
              color: Colors.white24,
              width: 3,
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(0xff7C3AED)
                    .withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
          ),

          child: CircleAvatar(
            radius: 62,
            backgroundColor: Colors.white10,

            backgroundImage: hasImage
                ? NetworkImage(
                    "${ApiConfig.baseUrl}/uploads/${state.lotti}",
                  )
                : null,

            child: !hasImage
                ? const Icon(
                    Icons.person_rounded,
                    size: 70,
                    color: Colors.white,
                  )
                : null,
          ),
        ),

        /// ONLINE INDICATOR
        Positioned(
          right: 10,
          bottom: 12,

          child: Container(
            height: 22,
            width: 22,

            decoration: BoxDecoration(
              color: state.online
                  ? Colors.greenAccent
                  : Colors.grey,

              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
                            const SizedBox(height: 22),

                            /// NAME
                            Text(
                              state.name.trim().isEmpty
                                  ? "Unknown User"
                                  : state.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// NICKNAME
                            Text(
                              state.nickName.trim().isEmpty
                                  ? "@convo_user"
                                  : "@${state.nickName}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 18),

                            /// STATUS CHIP
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: state.online
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: state.online
                                      ? Colors.greenAccent
                                      : Colors.white24,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: state.online
                                        ? Colors.greenAccent
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    state.online
                                        ? "Currently Online"
                                        : "Offline",
                                    style: TextStyle(
                                      color: state.online
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
              ///
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -2),

                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffF8FAFC),

                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          /// TOP HANDLE
                          Center(
                            child: Container(
                              height: 5,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          /// ACTION BUTTONS
                          Row(
                            children: [
                              Expanded(
                                child: _modernActionButton(
                                  icon: Icons.call_rounded,
                                  title: "Call",
                                  gradient: const [
                                    Color(0xff4F46E5),
                                    Color(0xff6366F1),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: _modernActionButton(
                                  icon: Icons.videocam_rounded,
                                  title: "Video",
                                  gradient: const [
                                    Color(0xff7C3AED),
                                    Color(0xffA855F7),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: _modernActionButton(
                                  icon: Icons.chat_bubble_rounded,
                                  title: "Chat",
                                  gradient: const [
                                    Color(0xff0EA5E9),
                                    Color(0xff38BDF8),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          /// SECTION TITLE
                          const Text(
                            "Profile Information",
                            style: TextStyle(
                              color: Color(0xff111827),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// PROFILE CARDS
                          _modernProfileCard(
                            icon: Icons.alternate_email_rounded,
                            title: "Nickname",
                            value: state.nickName.trim().isEmpty
                                ? "Not Added"
                                : state.nickName,
                          ),

                          _modernProfileCard(
                            icon: Icons.phone_rounded,
                            title: "Phone Number",
                            value: state.phone.trim().isEmpty
                                ? "Not Available"
                                : state.phone,
                          ),

                          _modernProfileCard(
                            icon: Icons.info_outline_rounded,
                            title: "About",
                            value: state.about.trim().isEmpty
                                ? "Hey there! I’m using ConVO."
                                : state.about,
                          ),

                          _modernProfileCard(
                            icon: Icons.lock_outline_rounded,
                            title: "Privacy",
                            value: "End-to-end encrypted conversations",
                          ),

                          const SizedBox(height: 30),

                          /// EDIT BUTTON
                          Container(
                            height: 60,
                            width: double.infinity,

                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff4F46E5), Color(0xff7C3AED)],
                              ),

                              borderRadius: BorderRadius.circular(22),

                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xff7C3AED,
                                  ).withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),

                            child: Material(
                              color: Colors.transparent,

                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),

                                onTap: () {},

                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                    ),

                                    SizedBox(width: 12),

                                    Text(
                                      "Edit Profile",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _modernProfileCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(26),

        border: Border.all(color: Colors.grey.shade100),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// ICON BOX
          Container(
            height: 60,
            width: 60,

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xff4F46E5).withOpacity(0.12),
                  const Color(0xff7C3AED).withOpacity(0.08),
                ],
              ),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Icon(icon, color: const Color(0xff4F46E5), size: 28),
          ),

          const SizedBox(width: 18),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  value,

                  style: const TextStyle(
                    color: Color(0xff111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _modernActionButton({
    required IconData icon,
    required String title,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(26),

        border: Border.all(color: Colors.grey.shade100),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          /// ICON CONTAINER
          Container(
            height: 58,
            width: 58,

            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),

              borderRadius: BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: gradient.first.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Icon(icon, color: Colors.white, size: 28),
          ),

          const SizedBox(height: 14),

          Text(
            title,

            style: const TextStyle(
              color: Color(0xff111827),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
