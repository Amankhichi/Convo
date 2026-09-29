import 'package:flutter/material.dart';

class CameraModeSelector extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onModeSelected;

  const CameraModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  static const List<String> modes = ['STORY', 'HANDS_FREE', 'BOOMERANG', 'LAYOUT'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: modes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (ctx, idx) {
          final mode = modes[idx];
          final isSelected = mode == selectedMode;

          return GestureDetector(
            onTap: () => onModeSelected(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black54 : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? Border.all(color: Colors.white70) : null,
              ),
              child: Center(
                child: Text(
                  mode.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
