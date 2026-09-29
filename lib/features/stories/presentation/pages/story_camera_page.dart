import 'dart:async';
import 'package:camera/camera.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/stories/camera/data/services/story_camera_service.dart';
import 'package:convo/features/stories/camera/presentation/bloc/story_camera_bloc.dart';
import 'package:convo/features/stories/camera/presentation/bloc/story_camera_event.dart';
import 'package:convo/features/stories/camera/presentation/bloc/story_camera_state.dart';
import 'package:convo/features/stories/camera/presentation/widgets/camera_filter_overlay.dart';
import 'package:convo/features/stories/camera/presentation/widgets/camera_filter_selector.dart';
import 'package:convo/features/stories/camera/presentation/widgets/camera_focus_indicator.dart';
import 'package:convo/features/stories/camera/presentation/widgets/camera_grid_overlay.dart';
import 'package:convo/features/stories/camera/presentation/widgets/camera_mode_selector.dart';
import 'package:convo/features/stories/presentation/pages/story_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class StoryCameraPage extends StatefulWidget {
  const StoryCameraPage({super.key});

  @override
  State<StoryCameraPage> createState() => _StoryCameraPageState();
}

class _StoryCameraPageState extends State<StoryCameraPage>
    with WidgetsBindingObserver {
  late StoryCameraService _cameraService;
  late StoryCameraBloc _cameraBloc;

  bool _hasPermission = false;
  bool _permissionChecked = false;

  // Zoom gesture handling
  double _baseScale = 1.0;

  // Tap to focus indicator
  Offset? _focusPoint;
  Timer? _focusTimer;

  // Drag exposure offset
  double _baseExposure = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraService = StoryCameraService();
    _cameraBloc = StoryCameraBloc(_cameraService);
    _requestPermissionsAndInit();
  }

  Future<void> _requestPermissionsAndInit() async {
    final cameraStatus = await Permission.camera.request();
    await Permission.microphone.request();

    if (cameraStatus.isGranted) {
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _permissionChecked = true;
        });
        _cameraBloc.add(const InitializeStoryCameraEvent());
      }
    } else {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _permissionChecked = true;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasPermission || !mounted) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraBloc.add(DisposeStoryCameraEvent());
    } else if (state == AppLifecycleState.resumed) {
      _cameraBloc.add(const InitializeStoryCameraEvent());
    }
  }

  void _onTapFocus(TapDownDetails details, StoryCameraReady readyState) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = details.localPosition;
    final double x = localOffset.dx / box.size.width;
    final double y = localOffset.dy / box.size.height;

    _cameraService.setFocusPoint(Offset(x, y));

    setState(() {
      _focusPoint = localOffset;
    });

    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _focusPoint = null;
        });
      }
    });
  }

  void _onScaleStart(ScaleStartDetails details, StoryCameraReady readyState) {
    _baseScale = readyState.currentZoom;
    _baseExposure = readyState.currentExposure;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, StoryCameraReady readyState) {
    if (details.scale != 1.0) {
      // Pinch Zoom
      final double newZoom = _baseScale * details.scale;
      _cameraBloc.add(SetZoomEvent(newZoom));
    } else if (details.focalPointDelta.dy != 0) {
      // Vertical Exposure Drag
      final double delta = -details.focalPointDelta.dy / 200;
      final double newExp = _baseExposure + delta;
      _cameraBloc.add(SetExposureEvent(newExp));
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      _navigateToEditor(file.path, 'IMAGE');
    }
  }

  void _navigateToEditor(String mediaPath, String mediaType) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StoryEditorPage(
          mediaPath: mediaPath,
          mediaType: mediaType,
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusTimer?.cancel();
    _cameraBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionChecked) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 64, color: Colors.white54),
                const SizedBox(height: 16),
                const Text(
                  "Camera Permission Required",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "ConVo needs camera and microphone access to create photo and video stories.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: _requestPermissionsAndInit,
                  child: const Text("Grant Permission"),
                ),
                TextButton(
                  onPressed: _pickFromGallery,
                  child: const Text("Pick from Gallery Instead", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider<StoryCameraBloc>.value(
      value: _cameraBloc,
      child: BlocConsumer<StoryCameraBloc, StoryCameraState>(
        listener: (context, state) {
          if (state is StoryCameraMediaCaptured) {
            _navigateToEditor(state.mediaPath, state.mediaType);
          } else if (state is StoryCameraError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StoryCameraLoading || state is StoryCameraInitial) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }

          if (state is StoryCameraReady) {
            final controller = _cameraService.controller;
            if (controller == null || !controller.value.isInitialized) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            final size = MediaQuery.of(context).size;
            final cameraAspect = controller.value.aspectRatio;

            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  // Device-Adaptive Camera Preview Container
                  GestureDetector(
                    onTapDown: (details) => _onTapFocus(details, state),
                    onDoubleTap: () => _cameraBloc.add(SwitchStoryCameraEvent()),
                    onScaleStart: (d) => _onScaleStart(d, state),
                    onScaleUpdate: (d) => _onScaleUpdate(d, state),
                    child: CameraFilterOverlay(
                      filterName: state.selectedFilter,
                      child: ClipRect(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: size.width,
                            height: size.width * cameraAspect,
                            child: CameraPreview(controller),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Rule-of-Thirds Grid Overlay
                  if (state.gridEnabled) const CameraGridOverlay(),

                  // Tap-to-Focus Indicator
                  if (_focusPoint != null) CameraFocusIndicator(point: _focusPoint!),

                  // Zoom & Exposure Feedback Overlay
                  Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${state.currentZoom.toStringAsFixed(1)}x  •  Exp: ${state.currentExposure > 0 ? '+' : ''}${state.currentExposure.toStringAsFixed(1)}",
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  // Top Action Bar Controls
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                            if (state.isRecording)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.fiber_manual_record, color: Colors.white, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      "00:${state.recordingSeconds.toString().padLeft(2, '0')}",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            Row(
                              children: [
                                if (state.capabilities.supportsFlash)
                                  IconButton(
                                    icon: Icon(
                                      state.flashMode == FlashMode.torch
                                          ? Icons.flash_on
                                          : Icons.flash_off,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () => _cameraBloc.add(ToggleFlashEvent()),
                                  ),
                                IconButton(
                                  icon: Icon(
                                    state.gridEnabled ? Icons.grid_on : Icons.grid_off,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () => _cameraBloc.add(ToggleGridEvent()),
                                ),
                                if (state.capabilities.hasFrontCamera && state.capabilities.hasBackCamera)
                                  IconButton(
                                    icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 26),
                                    onPressed: () => _cameraBloc.add(SwitchStoryCameraEvent()),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Controls Layout (Mode Selector, Filter Selector, Gallery, Shutter)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Live Filter Selector Bar
                          CameraFilterSelector(
                            selectedFilter: state.selectedFilter,
                            onFilterSelected: (f) => _cameraBloc.add(SetFilterEvent(f)),
                          ),

                          // Camera Mode Selector Bar (STORY, HANDS_FREE, BOOMERANG, LAYOUT)
                          CameraModeSelector(
                            selectedMode: state.selectedMode,
                            onModeSelected: (m) => _cameraBloc.add(SetCameraModeEvent(m)),
                          ),

                          // Main Shutter Button Bar
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Gallery Media Button
                                IconButton(
                                  icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                                  onPressed: _pickFromGallery,
                                ),

                                // Shutter Button (Tap = Photo, Long-Press = Video, Hands-Free = Tap toggle)
                                GestureDetector(
                                  onTap: () {
                                    if (state.selectedMode == 'HANDS_FREE') {
                                      if (state.isRecording) {
                                        _cameraBloc.add(StopVideoRecordingEvent());
                                      } else {
                                        _cameraBloc.add(StartVideoRecordingEvent());
                                      }
                                    } else {
                                      _cameraBloc.add(TakePhotoEvent());
                                    }
                                  },
                                  onLongPress: () {
                                    if (state.selectedMode != 'HANDS_FREE') {
                                      _cameraBloc.add(StartVideoRecordingEvent());
                                    }
                                  },
                                  onLongPressEnd: (_) {
                                    if (state.selectedMode != 'HANDS_FREE' && state.isRecording) {
                                      _cameraBloc.add(StopVideoRecordingEvent());
                                    }
                                  },
                                  child: Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 4),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: state.isRecording
                                              ? Colors.red
                                              : (state.selectedMode == 'BOOMERANG'
                                                  ? Colors.purpleAccent
                                                  : Colors.white),
                                        ),
                                        child: state.selectedMode == 'BOOMERANG'
                                            ? const Icon(Icons.all_inclusive, color: Colors.white, size: 28)
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 44),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        },
      ),
    );
  }
}
