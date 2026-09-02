import 'package:convo/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum AttachmentType {
  cameraImage,
  cameraVideo,
  galleryImage,
  galleryVideo,
  audio,
  document,
  location,
  contact,
}

class AttachmentBottomSheet extends StatelessWidget {
  final Function(AttachmentType) onSelect;

  const AttachmentBottomSheet({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOptionItem(
                context,
                icon: Icons.camera_alt,
                color: const Color(0xFFFF2D55),
                label: "Camera",
                onTap: () => onSelect(AttachmentType.cameraImage),
              ),
              _buildOptionItem(
                context,
                icon: Icons.photo_library,
                color: const Color(0xFF5856D6),
                label: "Gallery",
                onTap: () => onSelect(AttachmentType.galleryImage),
              ),
              _buildOptionItem(
                context,
                icon: Icons.videocam,
                color: const Color(0xFFFF9500),
                label: "Video",
                onTap: () => onSelect(AttachmentType.galleryVideo),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOptionItem(
                context,
                icon: Icons.audiotrack,
                color: const Color(0xFF007AFF),
                label: "Audio",
                onTap: () => onSelect(AttachmentType.audio),
              ),
              _buildOptionItem(
                context,
                icon: Icons.insert_drive_file,
                color: const Color(0xFF34C759),
                label: "Document",
                onTap: () => onSelect(AttachmentType.document),
              ),
              _buildOptionItem(
                context,
                icon: Icons.location_on,
                color: const Color(0xFFAF52DE),
                label: "Location",
                onTap: () => onSelect(AttachmentType.location),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
