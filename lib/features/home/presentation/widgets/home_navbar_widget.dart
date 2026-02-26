import 'package:convo/core/const.dart/app_colors.dart';
import 'package:flutter/material.dart';

class HomeNavbar extends StatefulWidget {
  final Function(int index)? onTabChanged;

  const HomeNavbar({super.key, this.onTabChanged});

  @override
  State<HomeNavbar> createState() => _HomeNavbarState();
}

class _HomeNavbarState extends State<HomeNavbar> {
  int selectedIndex = 0;

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
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        widget.onTabChanged?.call(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.green.shade400
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
                :AppColors.textColor(context),
          ),
        ),
      ),
    );
  }
}