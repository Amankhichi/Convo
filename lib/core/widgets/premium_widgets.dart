import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = true,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 68 : 82);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final showBackButton = showBack && (onBack != null || canPop);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              showBackButton ? 4 : 20,
              4,
              16,
              10,
            ),
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      if (onBack != null) {
                        onBack!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.78),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ...?actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const PremiumSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: context.appSurface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: context.appBorder),
              ),
              child: Icon(icon, color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appText,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appMutedText, height: 1.45),
            ),
            if (action != null) ...[const SizedBox(height: 22), action!],
          ],
        ),
      ),
    );
  }
}
