import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

abstract class StoryCameraEvent extends Equatable {
  const StoryCameraEvent();

  @override
  List<Object?> get props => [];
}

class InitializeStoryCameraEvent extends StoryCameraEvent {
  final CameraLensDirection preferredLens;

  const InitializeStoryCameraEvent({this.preferredLens = CameraLensDirection.back});

  @override
  List<Object?> get props => [preferredLens];
}

class SwitchStoryCameraEvent extends StoryCameraEvent {}

class ToggleFlashEvent extends StoryCameraEvent {}

class SetZoomEvent extends StoryCameraEvent {
  final double zoom;

  const SetZoomEvent(this.zoom);

  @override
  List<Object?> get props => [zoom];
}

class SetExposureEvent extends StoryCameraEvent {
  final double exposure;

  const SetExposureEvent(this.exposure);

  @override
  List<Object?> get props => [exposure];
}

class ToggleGridEvent extends StoryCameraEvent {}

class SetCameraModeEvent extends StoryCameraEvent {
  final String mode; // 'STORY', 'HANDS_FREE', 'BOOMERANG', 'LAYOUT'

  const SetCameraModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SetFilterEvent extends StoryCameraEvent {
  final String filter; // 'Normal', 'Vintage', 'Warm', 'Cool', 'B&W', 'Drama', 'Fade', 'Bright'

  const SetFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class TakePhotoEvent extends StoryCameraEvent {}

class StartVideoRecordingEvent extends StoryCameraEvent {}

class StopVideoRecordingEvent extends StoryCameraEvent {}

class DisposeStoryCameraEvent extends StoryCameraEvent {}
