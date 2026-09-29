import 'package:camera/camera.dart';
import 'package:convo/features/stories/camera/data/services/story_camera_service.dart';
import 'package:equatable/equatable.dart';

abstract class StoryCameraState extends Equatable {
  const StoryCameraState();

  @override
  List<Object?> get props => [];
}

class StoryCameraInitial extends StoryCameraState {}

class StoryCameraLoading extends StoryCameraState {}

class StoryCameraReady extends StoryCameraState {
  final CameraCapabilities capabilities;
  final CameraLensDirection currentLens;
  final FlashMode flashMode;
  final double currentZoom;
  final double currentExposure;
  final bool gridEnabled;
  final String selectedMode; // 'STORY', 'HANDS_FREE', 'BOOMERANG', 'LAYOUT'
  final String selectedFilter; // 'Normal', 'Vintage', 'Warm', 'Cool', 'B&W', 'Drama', 'Fade', 'Bright'
  final bool isRecording;
  final int recordingSeconds;

  const StoryCameraReady({
    required this.capabilities,
    required this.currentLens,
    required this.flashMode,
    required this.currentZoom,
    required this.currentExposure,
    this.gridEnabled = false,
    this.selectedMode = 'STORY',
    this.selectedFilter = 'Normal',
    this.isRecording = false,
    this.recordingSeconds = 0,
  });

  StoryCameraReady copyWith({
    CameraCapabilities? capabilities,
    CameraLensDirection? currentLens,
    FlashMode? flashMode,
    double? currentZoom,
    double? currentExposure,
    bool? gridEnabled,
    String? selectedMode,
    String? selectedFilter,
    bool? isRecording,
    int? recordingSeconds,
  }) {
    return StoryCameraReady(
      capabilities: capabilities ?? this.capabilities,
      currentLens: currentLens ?? this.currentLens,
      flashMode: flashMode ?? this.flashMode,
      currentZoom: currentZoom ?? this.currentZoom,
      currentExposure: currentExposure ?? this.currentExposure,
      gridEnabled: gridEnabled ?? this.gridEnabled,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isRecording: isRecording ?? this.isRecording,
      recordingSeconds: recordingSeconds ?? this.recordingSeconds,
    );
  }

  @override
  List<Object?> get props => [
        capabilities,
        currentLens,
        flashMode,
        currentZoom,
        currentExposure,
        gridEnabled,
        selectedMode,
        selectedFilter,
        isRecording,
        recordingSeconds,
      ];
}

class StoryCameraMediaCaptured extends StoryCameraState {
  final String mediaPath;
  final String mediaType; // 'IMAGE' or 'VIDEO'

  const StoryCameraMediaCaptured({
    required this.mediaPath,
    required this.mediaType,
  });

  @override
  List<Object?> get props => [mediaPath, mediaType];
}

class StoryCameraError extends StoryCameraState {
  final String message;

  const StoryCameraError(this.message);

  @override
  List<Object?> get props => [message];
}
