import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final bool isSelectionMode;
  final int selectedCount;
  final String displayName;
  final String displayImage;
  final bool displayOnline;
  final String presenceSubtitle;
  final PreferredSizeWidget searchAppBar;
  final List<Widget> selectionActions;
  final VoidCallback onBackPressed;
  final VoidCallback onClearSelection;
  final VoidCallback onOpenProfile;
  final VoidCallback onStartSearch;
  final VoidCallback? onStartCall;

  const ChatAppBar({
    super.key,
    required this.isSearching,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.displayName,
    required this.displayImage,
    required this.displayOnline,
    required this.presenceSubtitle,
    required this.searchAppBar,
    required this.selectionActions,
    required this.onBackPressed,
    required this.onClearSelection,
    required this.onOpenProfile,
    required this.onStartSearch,
    this.onStartCall,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isSearching) {
      return searchAppBar;
    }

    if (isSelectionMode) {
      return AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onClearSelection,
        ),
        title: Text(
          "$selectedCount selected",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: selectionActions,
      );
    }

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      elevation: 1,
      leadingWidth: 30,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: onBackPressed,
      ),
      title: GestureDetector(
        onTap: onOpenProfile,
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  backgroundImage: displayImage.isNotEmpty
                      ? NetworkImage(ApiConfig.sanitizeUrl(displayImage))
                      : null,
                  child: displayImage.isEmpty
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (displayOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    presenceSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: displayOnline ? Colors.green : AppColors.greyText(context),
                      fontWeight: displayOnline ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined, color: AppColors.primary),
          onPressed: onStartCall,
        ),
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.primary),
          onPressed: onStartSearch,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }
}
