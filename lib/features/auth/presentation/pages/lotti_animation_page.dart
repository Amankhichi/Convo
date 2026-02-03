import 'package:convo/features/auth/presentation/widgets/lotti_animation_widget.dart';
import 'package:convo/features/home/presentation/widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:convo/features/home/presentation/widgets/custom_text.dart';

class LottiAnimationPage extends StatelessWidget {
  const LottiAnimationPage({super.key, });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.of(context).pop();},icon: CustomIcon(icon: Icons.arrow_back,size: 35,),),
        centerTitle: true,
        title:  CustomText(
          text: "Select Profile",
          size: 23,
          bold: FontWeight.bold,
        ),
      ),
      body: Center(
  child: LottiAnimationWidget(),
),

    );
  }

}
