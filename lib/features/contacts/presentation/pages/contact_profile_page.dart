import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class ContactProfilePage extends StatelessWidget {
  final String name;
  final String phone;
  final String image;
  final String about;
  final bool isOnline;

  const ContactProfilePage({
    super.key,
    required this.name,
    required this.phone,
    required this.image,
    required this.about,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Info",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            /// Large Profile Photo Avatar
            GestureDetector(
              onTap: () {
                if (image.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.black,
                      child: InteractiveViewer(
                        child: Image.network(image, fit: BoxFit.contain),
                      ),
                    ),
                  );
                }
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: AppColors.primary,
                    backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                    child: image.isEmpty
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "?",
                            style: const TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor(context),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              phone.isNotEmpty ? phone : "ConVo User",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText(context),
              ),
            ),

            const SizedBox(height: 24),

            /// Quick Actions Bar (Call, Video, Message)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.chat,
                  label: "Message",
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  context,
                  icon: Icons.call,
                  label: "Audio",
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  context,
                  icon: Icons.videocam,
                  label: "Video",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),

            /// About Section
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              title: Text(
                about.isNotEmpty ? about : "Hey there! I am using ConVo.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor(context),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "About",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.greyText(context),
                  ),
                ),
              ),
              leading: const Icon(Icons.info_outline, color: AppColors.primary),
            ),

            const Divider(height: 1),

            /// Encryption & Security Card
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              leading: const Icon(Icons.lock_outline, color: AppColors.primary),
              title: const Text(
                "Encryption",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                "Messages and calls are end-to-end encrypted. Tap to verify.",
              ),
            ),

            const Divider(height: 1),

            /// Block & Report
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              leading: const Icon(Icons.block, color: Colors.red),
              title: Text(
                "Block $name",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {},
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              leading: const Icon(Icons.thumb_down_outlined, color: Colors.red),
              title: Text(
                "Report $name",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
      ],
    );
  }
}
