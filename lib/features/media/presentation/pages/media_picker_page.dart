import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/stories/presentation/pages/story_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerPage extends StatelessWidget {
  const MediaPickerPage({super.key});

  Future<void> _pickMedia(BuildContext context, {required bool isVideo}) async {
    final picker = ImagePicker();
    final file = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);

    if (file != null && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StoryEditorPage(
            mediaPath: file.path,
            mediaType: isVideo ? 'VIDEO' : 'IMAGE',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Media", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AppColors.primary.withAlpha(20),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text("Choose Photo from Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Select image file"),
                onTap: () => _pickMedia(context, isVideo: false),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.pink.withAlpha(20),
                leading: const CircleAvatar(
                  backgroundColor: Colors.pink,
                  child: Icon(Icons.videocam, color: Colors.white),
                ),
                title: const Text("Choose Video from Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Select video file"),
                onTap: () => _pickMedia(context, isVideo: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
