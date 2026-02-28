// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:convo/core/model/stroy_model.dart';

// class AddStoryPage extends StatefulWidget {
//   const AddStoryPage({super.key});

//   @override
//   State<AddStoryPage> createState() => _AddStoryPageState();
// }

// class _AddStoryPageState extends State<AddStoryPage> {
//   CameraController? _controller;
//   List<CameraDescription>? cameras;
//   bool isReady = false;
//   int selectedCameraIndex = 0;
//   FlashMode flashMode = FlashMode.off;

//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     initCamera();
//   }

//   /// 🔥 Initialize Camera
//   Future<void> initCamera() async {
//     cameras = await availableCameras();

//     _controller = CameraController(
//       cameras![selectedCameraIndex],
//       ResolutionPreset.high,
//     );

//     await _controller!.initialize();

//     if (!mounted) return;

//     setState(() {
//       isReady = true;
//     });
//   }

//   /// 🔁 Switch Front / Back
//   Future<void> switchCamera() async {
//     selectedCameraIndex =
//         selectedCameraIndex == 0 ? 1 : 0;

//     await _controller?.dispose();
//     await initCamera();
//   }

//   /// ⚡ Flash Toggle
//   Future<void> toggleFlash() async {
//     flashMode =
//         flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;

//     await _controller?.setFlashMode(flashMode);
//     setState(() {});
//   }

//   /// 📸 Capture Image
//   Future<void> captureImage() async {
//     final file = await _controller!.takePicture();

//     if (!mounted) return;

//     Navigator.pop(
//       context,
//       StoryModel(
//         username: "You",
//         imageUrl: file.path,
//         isMyStory: true,
//       ),
//     );
//   }

//   /// 🖼 Pick From Gallery
//   Future<void> pickFromGallery() async {
//     final XFile? image = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//     );

//     if (image != null) {
//       Navigator.pop(
//         context,
//         StoryModel(
//           username: "You",
//           imageUrl: image.path,
//           isMyStory: true,
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: isReady
//           ? Stack(
//               children: [

//                 /// 🔥 Camera Preview
//                 CameraPreview(_controller!),

//                 /// 🔝 Top Controls
//                 Positioned(
//                   top: 50,
//                   left: 20,
//                   right: 20,
//                   child: Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         onPressed: toggleFlash,
//                         icon: Icon(
//                           flashMode == FlashMode.off
//                               ? Icons.flash_off
//                               : Icons.flash_on,
//                           color: Colors.white,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: switchCamera,
//                         icon: const Icon(
//                           Icons.flip_camera_ios,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 /// 🔘 Bottom Controls
//                 Positioned(
//                   bottom: 40,
//                   left: 0,
//                   right: 0,
//                   child: Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.spaceEvenly,
//                     children: [

//                       /// 🖼 Gallery Button
//                       IconButton(
//                         onPressed: pickFromGallery,
//                         icon: const Icon(
//                           Icons.photo,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),

//                       /// 📸 Capture Button
//                       GestureDetector(
//                         onTap: captureImage,
//                         child: Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                                 color: Colors.white, width: 5),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 30),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           : const Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
// }



import 'package:camera/camera.dart';
import 'package:convo/features/home/presentation/pages/view_image_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:convo/core/model/stroy_model.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  CameraController? controller;
  int cameraIndex = 0;
  FlashMode flashMode = FlashMode.off;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
    );
    await controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _switchCamera() async {
    cameraIndex = cameraIndex == 0 ? 1 : 0;
    await controller?.dispose();
    _initCamera();
  }

  Future<void> _toggleFlash() async {
    flashMode =
        flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await controller?.setFlashMode(flashMode);
    setState(() {});
  }

  Future<void> _capture() async {
    final file = await controller!.takePicture();
    Navigator.pop(
      context,
      StoryModel(
        username: "You",
        imageUrl: file.path,
        isMyStory: true,
      ),
    );
  }

Future<void> _openGallery() async {
  final image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewImagePage(imagePath: image.path),
      ),
    );
  }
}

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// Camera
          Positioned.fill(child: CameraPreview(controller!)),

          /// Top Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _icon(Icons.close, () => Navigator.pop(context)),
                _icon(
                  flashMode == FlashMode.off
                      ? Icons.flash_off
                      : Icons.flash_on,
                  _toggleFlash,
                ),
              ],
            ),
          ),

          /// Flip Camera
          Positioned(
            right: 20,
            bottom: 150,
            child: _icon(Icons.flip_camera_ios, _switchCamera),
          ),

          /// Bottom Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _icon(Icons.photo, _openGallery),

                GestureDetector(
                  onTap: _capture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 5),
                    ),
                  ),
                ),

                const SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
