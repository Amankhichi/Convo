import 'package:convo/const.dart/app_colors.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:flutter/material.dart';

class HomeDrawerWidget extends StatelessWidget {
  final UserModel user;

  final VoidCallback onProfileTap;

  final VoidCallback onSettingsTap;

  final VoidCallback onAboutTap;

  final VoidCallback onLogout;

  const HomeDrawerWidget({
    super.key,
    required this.user,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onAboutTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * .50;

    return SizedBox(
      width: drawerWidth,

      child: Drawer(
        elevation: 0,

        backgroundColor: AppColors.backgroundColor(context),

        child: SafeArea(
          child: Column(
            children: [
              /// ================= HEADER =================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,

                    colors: [
                      AppColors.primary,

                      AppColors.primary.withOpacity(.75),
                    ],
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// PROFILE
                    CircleAvatar(
                      radius: 35,

                      backgroundColor: Colors.white,

                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",

                        style: TextStyle(
                          color: AppColors.primary,

                          fontSize: 30,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// NAME
                    Text(
                      user.name,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 20,

                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// PHONE
                    Text(
                      user.phone,

                      style: TextStyle(
                        color: Colors.white.withOpacity(.85),

                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// ================= ITEMS =================
              _drawerItem(
                context: context,

                icon: Icons.person_outline,

                title: "Profile",

                onTap: onProfileTap,
              ),

              _drawerItem(
                context: context,

                icon: Icons.settings_outlined,

                title: "Settings",

                onTap: onSettingsTap,
              ),

              _drawerItem(
                context: context,

                icon: Icons.info_outline,

                title: "About",

                onTap: onAboutTap,
              ),

              const Spacer(),

              /// ================= LOGOUT =================
              Padding(
                padding: const EdgeInsets.all(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.red.withOpacity(.25)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    );
  }

  /// ================= LOGOUT DIALOG =================

  void _showLogoutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,

      barrierDismissible: true,

      barrierLabel: "Logout",

      barrierColor: Colors.black.withOpacity(.60),

      transitionDuration: const Duration(milliseconds: 280),

      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,

            child: Container(
              width: MediaQuery.of(context).size.width * .84,

              margin: const EdgeInsets.symmetric(horizontal: 24),

              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),

              decoration: BoxDecoration(
                color: AppColors.backgroundColor(context),

                borderRadius: BorderRadius.circular(32),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.25),

                    blurRadius: 30,

                    offset: const Offset(0, 12),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  /// ICON
                  Container(
                    height: 92,
                    width: 92,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade700],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(.35),

                          blurRadius: 24,

                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.logout_rounded,

                      color: Colors.white,

                      size: 42,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// TITLE
                  Text(
                    "Logout Account",

                    style: TextStyle(
                      color: AppColors.textColor(context),

                      fontSize: 24,

                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// SUBTITLE
                  Text(
                    "Are you sure you want to logout from your ConVO account?",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: AppColors.textColor(context).withOpacity(.7),

                      fontSize: 15,

                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BUTTONS
                  Row(
                    children: [
                      /// CANCEL
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),

                            side: BorderSide(
                              color: AppColors.primary,
                              width: 1.4,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: Text(
                            "Cancel",

                            style: TextStyle(
                              color: AppColors.primary,

                              fontSize: 15,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// LOGOUT
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,

                            elevation: 0,

                            padding: const EdgeInsets.symmetric(vertical: 15),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          onPressed: () {
                            Navigator.pop(context);

                            onLogout();
                          },

                          child: const Text(
                            "Logout",

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 15,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },

      transitionBuilder: (_, animation, __, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(animation.value),

          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  /// ================= DRAWER ITEM =================

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(14),

          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

            child: Row(
              children: [
                Icon(icon, color: AppColors.iconColor),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,

                    style: TextStyle(
                      color: AppColors.textColor(context),

                      fontSize: 15,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,

                  size: 15,

                  color: AppColors.iconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
