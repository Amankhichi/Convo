import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../../../core/utils/status.dart';
import '../../../../core/widgets/snackbar_widgets.dart';
import '../bloc/login_bloc.dart';

class AddNamePage extends StatefulWidget {
  const AddNamePage({super.key, required this.lotti, this.mobileNumber});

  final String lotti;
  final String? mobileNumber;

  @override
  State<AddNamePage> createState() => _AddNamePageState();
}

class _AddNamePageState extends State<AddNamePage> {
  final picker = ImagePicker();

  Uint8List? image;
  bool isUploading = false;

  final name = TextEditingController();
  final about = TextEditingController(text: "I'm busy in ConVO");

  final aboutList = [
    "I'm busy in ConVO",
    "I'm studying 📚",
    "Hanging with friends 😄",
  ];

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final file = await picker.pickImage(source: source);
    if (file == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Profile Picture',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      final bytes = await croppedFile.readAsBytes();
      setState(() => image = bytes);
    }
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty) {
      showError(context, "Enter your name");
      return;
    }

    setState(() => isUploading = true);

    try {
      String profileId = widget.lotti;

      if (image != null) {
        final upload = await getIt<FileUploadService>().uploadFile(image!);
        if (upload != null) {
          profileId = upload["id"].toString();
        } else {
          showError(context, "Upload failed");
          setState(() => isUploading = false);
          return;
        }
      }

      context.read<LoginBloc>()
        ..add(LoginEvent.nickName(name.text.trim()))
        ..add(LoginEvent.about(about.text))
        ..add(LoginEvent.lotti(profileId))
        ..add(LoginEvent.add());
    } catch (e) {
      showError(context, "An error occurred: $e");
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (_, state) {
        if (state.adduserStatus == Status.success) {
          setState(() => isUploading = false);
          context.go('/home');
        }

        if (state.adduserStatus == Status.error) {
          setState(() => isUploading = false);
          showError(context, "Something went wrong");
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 0,
          title: const Text("Create Profile"),
          centerTitle: true,
        ),
        bottomNavigationBar: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final isLoading = isUploading || state.adduserStatus == Status.loading;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : save,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Continue", style: TextStyle(fontSize: 18)),
                ),
              ),
            );
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: image != null
                            ? MemoryImage(image!)
                            : null,
                        child: image == null
                            ? const Icon(
                                Icons.person,
                                size: 55,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: pickImage,
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: "Name",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: about.text,
                    decoration: InputDecoration(
                      labelText: "About",
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: aboutList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      about.text = v!;
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Adding a profile photo is optional.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
