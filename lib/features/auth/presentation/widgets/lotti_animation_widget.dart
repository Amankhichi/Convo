import 'package:convo/features/home/presentation/bloc/singup_bloc/singup_bloc.dart';
import 'package:convo/features/home/presentation/pages/add_name_page.dart';
import 'package:convo/features/home/presentation/widgets/custom_text.dart';
import 'package:convo/features/home/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class LottiAnimationWidget extends StatelessWidget {
  const LottiAnimationWidget({super.key});

  static const List<String> lottiList = [
    'assests/lotti/[BB] Brick breathing.json',
    'assests/lotti/Cute person.json',
    'assests/lotti/Happy user.json',
    'assests/lotti/Indian.json',
    'assests/lotti/Kyra-avatar-animated.json',
    'assests/lotti/men-face-winkling.json',
    'assests/lotti/Muslim Woman.json',
    'assests/lotti/person1.json',
    'assests/lotti/Personal Character.json',
    'assests/lotti/Pirate.json',
    'assests/lotti/Taking Pictures.json',
    'assests/lotti/Woman Hair.json',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: lottiList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: CustomText(text: 'Add Avatar',size: 25,),
                    content: SizedBox(
                      height: 150,
                      width: 150,
                      child: Lottie.asset(
                        lottiList[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                    actions: [
                      Column(
                        children: [
                          CustomTextfield(label: "Nick name", onChanged: (v){context.read<SingupBloc>().add(SingupEvent.nickName(v));}),

                          TextButton(
                            onPressed: () { 
                              context.read<SingupBloc>().add(SingupEvent.lotti(lottiList[index]));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddNamePage(
                                    lotti: lottiList[index],
                                  ),
                                ),
                              );
                            },
                            child: CustomText(text:
                              "Add",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ClipOval(
                    child: SizedBox(
                      height: 90,
                      width: 90,
                      child: Lottie.asset(
                        lottiList[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
