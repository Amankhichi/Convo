import 'dart:typed_data';
import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/constants/storage_keys.dart';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/core/utils/validators.dart';
import 'package:convo/core/widgets/app_button.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:convo/features/authentication/domain/repositories/auth_repository.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController(
    text: "Hey there! I am using ConVo.",
  );

  Uint8List? imageBytes;
  bool isLoading = false;

  final List<String> presetAboutOptions = [
    "Hey there! I am using ConVo.",
    "Available",
    "Busy",
    "At work",
    "In a meeting",
    "At school",
    "At the gym",
    "Sleeping",
    "Urgent calls only",
    "Can't talk, ConVo only",
  ];

  @override
  void dispose() {
    nameController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => imageBytes = bytes);
  }

  Future<void> _saveProfile() async {
    final nameError = Validators.validateName(nameController.text);
    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nameError), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await sl<AuthRepository>().createProfile(
        nameController.text.trim(),
        aboutController.text.trim(),
        imageBytes,
      );

      final localStorage = sl<LocalStorage>();
      await localStorage.setString(
        StorageKeys.name,
        nameController.text.trim(),
      );
      await localStorage.setString(
        StorageKeys.about,
        aboutController.text.trim(),
      );

      if (res["data"] != null && res["data"] is Map<String, dynamic>) {
        final data = res["data"] as Map<String, dynamic>;
        if (data["profileImage"] != null) {
          await localStorage.setString(
            StorageKeys.profileImage,
            data["profileImage"].toString(),
          );
        }
      }

      if (!mounted) return;
      setState(() => isLoading = false);

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteNames.home, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFCBD5E1);

    return AppScaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     "Profile Setup",
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Create your profile",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your name and optional photo so friends can identify you.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyText(context),
              ),
            ),
            const SizedBox(height: 32),

            /// Profile Photo Picker Badge
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: containerBg,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: imageBytes != null
                          ? Image.memory(imageBytes!, fit: BoxFit.cover)
                          : Icon(
                              Icons.person,
                              size: 65,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            /// Name Label & TextField
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Name *",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor(context),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor(context),
              ),
              decoration: InputDecoration(
                hintText: "Enter your full name",
                hintStyle: TextStyle(
                  color: AppColors.greyText(context).withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: containerBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// About Label & TextField (Dual Mode: Direct Type or Select Dropdown)
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "About",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  Text(
                    "Type custom or pick option below",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: aboutController,
              readOnly: false, // Fully editable by user directly!
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor(context),
              ),
              decoration: InputDecoration(
                hintText: "Write your custom status...",
                hintStyle: TextStyle(
                  color: AppColors.greyText(context).withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: containerBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (aboutController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: "Clear About text",
                        onPressed: () {
                          setState(() {
                            aboutController.clear();
                          });
                        },
                      ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      tooltip: "Select from preset status options",
                      onSelected: (selectedOption) {
                        setState(() {
                          aboutController.text = selectedOption;
                          aboutController.selection =
                              TextSelection.fromPosition(
                                TextPosition(offset: selectedOption.length),
                              );
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          enabled: false,
                          child: Text(
                            "--- Select Quick Status ---",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        ...presetAboutOptions.map(
                          (opt) => PopupMenuItem<String>(
                            value: opt,
                            child: Row(
                              children: [
                                Icon(
                                  aboutController.text == opt
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 18,
                                  color: aboutController.text == opt
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      fontWeight: aboutController.text == opt
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// Continue Button
            AppButton(
              text: "Save & Continue",
              isLoading: isLoading,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
