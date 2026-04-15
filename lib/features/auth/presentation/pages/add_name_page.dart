import 'dart:typed_data';

import 'package:convo/core/const.dart/snakbar_status.dart';
import 'package:convo/core/const.dart/upload_file.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/auth/presentation/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocListener, ReadContext;
import 'package:image_picker/image_picker.dart';

class AddNamePage extends StatefulWidget {
  const AddNamePage({super.key, required this.lotti});
  final String lotti;

  @override
  State<AddNamePage> createState() => _AddNamePageState();
}

class _AddNamePageState extends State<AddNamePage> {
  final picker = ImagePicker();
  Uint8List? imageBytes;

  final nameController = TextEditingController();
  final aboutController = TextEditingController(text: "I'm busy in ConVO");

  final options = [
    "I'm busy in ConVO",
    "I'm studying 📚",
    "Hanging with friends 😄",
  ];

  /// 🔥 PICK IMAGE
  Future<void> pickImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    imageBytes = await file.readAsBytes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
  if (state.adduserStatus == Status.success) {
    showSuccess(context, "Saved successfully");
    Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomePage()),
          );
  } else if (state.adduserStatus == Status.error) {
    showError(context, "Not saved");
  }
},
      child: Scaffold(
        appBar: AppBar(title: const Text("Profile")),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// 🔥 AVATAR
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imageBytes != null
                      ? MemoryImage(imageBytes!)
                      : null,
                  child: imageBytes == null
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 NAME
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full name"),
                onChanged: (v) =>
                    context.read<LoginBloc>().add(LoginEvent.nickName(v)),
              ),

              const SizedBox(height: 20),

              /// 🔥 ABOUT
              TextField(
                controller: aboutController,
                onChanged: (v) =>
                    context.read<LoginBloc>().add(LoginEvent.about(v)),
                decoration: InputDecoration(
                  labelText: "About",
                  suffixIcon: PopupMenuButton<String>(
                    onSelected: (v) {
                      aboutController.text = v;
                      context.read<LoginBloc>().add(LoginEvent.about(v));
                    },
                    itemBuilder: (_) => options
                        .map((e) => PopupMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// 🔥 NEXT BUTTON
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () async {
  if (nameController.text.isEmpty) {
    showError(context, "Enter name");
    return;
  }

  if (imageBytes == null) {
    showError(context, "Select image");
    return;
  }

  final upload = await uploadFileWeb(imageBytes!);
  final fileId = upload?['id'];

  if (fileId == null) {
    showError(context, "Upload failed");
    return;
  }

  context.read<LoginBloc>().add(
        LoginEvent.lotti(fileId.toString()),
      );

  context.read<LoginBloc>().add(LoginEvent.add());
},
            child: const Text("Next"),
          ),
        ),
      ),
    );
  }
}
