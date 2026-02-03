import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
CustomText({
  super.key,
  required this.text,
  this.size = 18,
  this.clr = const Color(0xFF0088CC),
  this.bold=FontWeight.bold,
});

  final String text;
  final double size;
  final Color clr;
  final FontWeight bold;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(8),
    child: Text(text,style: TextStyle(color: clr,fontSize: size,fontWeight:bold ),),
    );
  }
}