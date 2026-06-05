import 'package:convo/const.dart/app_colors.dart';
import 'package:convo/const.dart/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool selectionMode;

  final bool isSearching;

  final int selectedCount;

  final VoidCallback onMenuTap;

  final VoidCallback onBackTap;

  final VoidCallback onSearchTap;

  final VoidCallback onDeleteTap;

  final VoidCallback onStarTap;

  final TextEditingController searchController;

  final Function(String) onSearch;

  const HomeAppBarWidget({
    super.key,

    required this.selectionMode,

    required this.isSearching,

    required this.selectedCount,

    required this.onMenuTap,

    required this.onBackTap,

    required this.onSearchTap,

    required this.onDeleteTap,

    required this.onStarTap,

    required this.searchController,

    required this.onSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,

      titleSpacing: 0,

      centerTitle: false,

      automaticallyImplyLeading: false,

      backgroundColor: AppColors.backgroundColor(context),

      /// LEADING
      leading: selectionMode
          ? IconButton(
              icon: const Icon(Icons.arrow_back),

              color: AppColors.iconColor,

              onPressed: onBackTap,
            )
          : isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back),

              color: AppColors.iconColor,

              onPressed: onBackTap,
            )
          : IconButton(
              icon: const Icon(Icons.menu),

              color: AppColors.textColor(context),

              onPressed: onMenuTap,
            ),

      /// TITLE
      title: selectionMode
          ? Text(
              "$selectedCount selected",

              style: TextStyle(
                color: AppColors.iconColor,

                fontWeight: FontWeight.w600,
              ),
            )
          : isSearching
          ? Container(
              height: 46,

              margin: const EdgeInsets.only(right: 10),

              decoration: BoxDecoration(
                color: AppColors.backgroundColor(context),

                borderRadius: BorderRadius.circular(16),
              ),

              child: AppTextField(
                controller: searchController,

                autofocus: true,

                textColor: AppColors.textColor(context),

                hintText: "Search chats...",

                prefixIcon: Icons.search,

                iconColor: AppColors.iconColor,

                fillColor: Colors.transparent,

                onChanged: onSearch,
              ),
            )
          : Text(
              "ConVO",

              style: GoogleFonts.courgette(
                fontSize: 34,

                fontWeight: FontWeight.w600,

                color: AppColors.primary,
              ),
            ),

      /// ACTIONS
      actions: selectionMode
          ? [
              IconButton(
                icon: const Icon(Icons.star),

                color: AppColors.iconColor,

                onPressed: onStarTap,
              ),

              IconButton(
                icon: const Icon(Icons.delete),

                color: AppColors.iconColor,

                onPressed: onDeleteTap,
              ),
            ]
          : [
              if (!isSearching)
                IconButton(
                  icon: Icon(
                    Icons.search,

                    color: AppColors.textColor(context),
                    size: 25,
                  ),

                  onPressed: onSearchTap,
                ),

              const SizedBox(width: 8),
            ],
    );
  }
}
