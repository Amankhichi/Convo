import 'package:convo/const.dart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/status.dart';
import '../../../../core/widgets/snackbar_widgets.dart';
import '../bloc/login_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController aboutController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<LoginBloc>().state;
    nameController = TextEditingController(text: state.nickName);
    phoneController = TextEditingController(text: state.phone);
    aboutController = TextEditingController(text: state.about);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  void saveChanges() {
    if (nameController.text.trim().isEmpty) {
      showError(context, "Name cannot be empty");
      return;
    }

    setState(() => isSaving = true);

    final state = context.read<LoginBloc>().state;
    context.read<LoginBloc>()
      ..add(LoginEvent.nickName(nameController.text.trim()))
      ..add(LoginEvent.phone(phoneController.text.trim()))
      ..add(LoginEvent.about(aboutController.text.trim()))
      ..add(LoginEvent.lotti(state.lotti))
      ..add(const LoginEvent.add());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.adduserStatus == Status.success && isSaving) {
          setState(() => isSaving = false);
          showSuccess(context, "Profile updated successfully");
          context.pop();
        } else if (state.adduserStatus == Status.error && isSaving) {
          setState(() => isSaving = false);
          showError(context, "Failed to update profile");
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff0F172A),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xff0F172A),
          centerTitle: true,
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final profileUrl = state.lotti.isNotEmpty
                ? "${ApiConfig.baseUrl}/uploads/${state.lotti}"
                : "";

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white12,
                        backgroundImage: profileUrl.isNotEmpty
                            ? NetworkImage(profileUrl)
                            : null,
                        child: profileUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: nameController,
                    hint: "Enter name",
                    label: "Name",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: phoneController,
                    hint: "Enter phone",
                    label: "Phone",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    readOnly: true, // Keep phone readOnly like typical apps
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: aboutController,
                    hint: "Write about yourself",
                    label: "About",
                    icon: Icons.info,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(icon, color: Colors.white70),
            filled: true,
            fillColor: const Color(0xff1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
