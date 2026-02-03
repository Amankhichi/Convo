import 'package:convo/core/const.dart/app_colors.dart';
import 'package:flutter/material.dart';

class CustomScreen extends StatelessWidget {
  const CustomScreen({super.key, required this.title, this.action=false, required this.child});
  final String title;
  final bool? action;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        // if(action==true){
        //   actions: [

        //   ],
        // }
      ),
      body: child,
    );
  }
}