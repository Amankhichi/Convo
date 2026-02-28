import 'package:convo/core/const.dart/app_colors.dart';
import 'package:flutter/material.dart';

class HomeNavbar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const HomeNavbar({
    super.key,
    required this.onTabChanged,
    required this.selectedIndex,
  });

  @override
  State<HomeNavbar> createState() => _HomeNavbarState();
}

class _HomeNavbarState extends State<HomeNavbar> {

  final List<String> tabs = [
    "All",
    "Unread 99+",
    "Call",
    "Groups 17",
    "Channel",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _buildTab(index),
          );
        },
      ),
    );
  }

  Widget _buildTab(int index) {
    final bool isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () {
        widget.onTabChanged(index); 
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textColor(context),
          ),
        ),
        child: Text(
          tabs[index],
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : AppColors.textColor(context),
          ),
        ),
      ),
    );
  }
}

