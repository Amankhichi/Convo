import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/pages/welcome_page.dart';
import 'package:convo/features/home/presentation/bloc/singup_bloc/singup_bloc.dart';
import 'package:convo/features/home/presentation/pages/singup_page.dart';
import 'package:convo/features/home/presentation/widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:convo/features/auth/presentation/pages/lotti_animation_page.dart';
import 'package:convo/features/home/presentation/widgets/custom_textfield.dart';
import 'package:convo/features/home/presentation/widgets/custom_text.dart';

class AddNamePage extends StatefulWidget {
  const AddNamePage({super.key, required this.lotti});
  final String lotti;

  @override
  State<AddNamePage> createState() => _AddNamePageState();
}

class _AddNamePageState extends State<AddNamePage> {
  TextEditingController nameController = TextEditingController();

  final TextEditingController controller = TextEditingController(
    text: "I'm busy in ConVO",
  );

  final List<String> options = [
    "I'm busy in ConVO",
    "I'm studying 📚",
    "Hanging with friends 😄",
    "Travelling ✈️",
    "At work 💼",
    "In a meeting 🤝",
    "Gaming 🎮",
    "Watching movies 🎬",
    "Listening music 🎧",
    "Chilling 😎",
  ];
  @override
  Widget build(BuildContext context) {
    return BlocListener<SingupBloc, SingupState>(
      listener: (context, state) {
        if (state.adduserStatus == Status.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomePage()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(

          leading: IconButton(
            color: AppColors.textColor(context),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const SingupPage()));
            },
            icon: CustomIcon(icon: Icons.arrow_back, size: 35,),
          ),
          title: CustomText(text: "Profile", bold: FontWeight.w800, size: 26),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              ClipOval(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: widget.lotti.isEmpty
                      ? const Icon(Icons.person, size: 80, color: Colors.grey)
                      : Lottie.asset(widget.lotti, fit: BoxFit.contain),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LottiAnimationPage(),
                    ),
                  );
                },
                child: const Text("Add Avatar"),
              ),

              const SizedBox(height: 20),

              CustomTextfield(
                controller: nameController,
                label: "Full name",
                onChanged: (value) {
                  context.read<SingupBloc>().add(SingupEvent.name(value));
                },
              ),

              const SizedBox(height: 20),

              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "About",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: PopupMenuButton<String>(
                    position: PopupMenuPosition.over,
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (v) =>
                        context.read<SingupBloc>().add(SingupEvent.about(v)),
                    itemBuilder: (_) => options
                        .map((e) => PopupMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Flutter Developer passionate about building beautiful apps.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: BlocBuilder<SingupBloc, SingupState>(
            builder: (context, state) {
              return SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.name.isEmpty
                      ? null
                      : () {
                          context.read<SingupBloc>().add(SingupEvent.add());
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      color: state.name.isEmpty
                          ? Colors.grey.shade700
                          : Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
