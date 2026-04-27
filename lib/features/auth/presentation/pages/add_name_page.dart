import 'dart:typed_data';

import 'package:convo/core/const.dart/snakbar_status.dart';
import 'package:convo/core/const.dart/upload_file.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/auth/presentation/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocListener, ReadContext;
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';

class AddNamePage extends StatefulWidget {
  const AddNamePage({super.key, required this.lotti});
  final String lotti;

  @override
  State<AddNamePage> createState() => _AddNamePageState();
}

class _AddNamePageState extends State<AddNamePage> {
  final picker = ImagePicker();
  Uint8List? img;

  final name = TextEditingController();
  final about = TextEditingController(text: "I'm busy in ConVO");

  final options = [
    "I'm busy in ConVO",
    "I'm studying 📚",
    "Hanging with friends 😄",
  ];

  /// 🔥 Pick Image
  Future<void> pickImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();

    /// 🔥 Open editor (WhatsApp-like)
    final edited = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImageEditor(image: bytes)),
    );

    if (edited != null) {
      img = edited; // edited Uint8List
      setState(() {});
    }
  }

  /// 🔥 Upload + Save
  Future<void> save() async {
    if (name.text.isEmpty) return showError(context, "Enter name");
    if (img == null) return showError(context, "Select image");

    final upload = await uploadFile(img!);
    if (upload == null) return showError(context, "Upload failed");

    context.read<LoginBloc>()
      ..add(LoginEvent.nickName(name.text))
      ..add(LoginEvent.about(about.text))
      ..add(LoginEvent.lotti(upload['id'].toString()))
      ..add(LoginEvent.add());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (_, state) {
        if (state.adduserStatus == Status.success) {
          showSuccess(context, "Saved");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomePage()),
          );
        } else if (state.adduserStatus == Status.error) {
          showError(context, "Failed");
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// 🔥 Avatar
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 3),
                  ),
                  child: ClipOval(
                    child: img != null
                        ? Image.memory(
                            img!,
                            width: 120, // 2 * radius
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 Name
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: "Full name"),
              ),

              const SizedBox(height: 20),

              /// 🔥 About
              TextField(
                controller: about,
                decoration: InputDecoration(
                  labelText: "About",
                  suffixIcon: PopupMenuButton<String>(
                    onSelected: (v) => setState(() => about.text = v),
                    itemBuilder: (_) => options
                        .map((e) => PopupMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// 🔥 Button
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(onPressed: save, child: const Text("Next")),
        ),
      ),
    );
  }
}
