import 'package:flutter/material.dart';

class CameraFilterSelector extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const CameraFilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const List<String> filters = [
    'Normal',
    'Vintage',
    'Warm',
    'Cool',
    'B&W',
    'Drama',
    'Fade',
    'Bright',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, idx) {
          final filter = filters[idx];
          final isSelected = filter == selectedFilter;

          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : Colors.black38,
                borderRadius: BorderRadius.circular(14),
                border: isSelected ? Border.all(color: Colors.white) : null,
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white70,
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
