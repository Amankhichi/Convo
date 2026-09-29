import 'dart:async';
import 'package:camera/camera.dart';
import 'package:convo/features/stories/camera/data/services/story_camera_service.dart';
import 'package:convo/features/stories/camera/presentation/bloc/story_camera_event.dart';
import 'package:convo/features/stories/camera/presentation/bloc/story_camera_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryCameraBloc extends Bloc<StoryCameraEvent, StoryCameraState> {
  final StoryCameraService _service;
  Timer? _recordingTimer;

  StoryCameraBloc(this._service) : super(StoryCameraInitial()) {
    on<InitializeStoryCameraEvent>(_onInitialize);
    on<SwitchStoryCameraEvent>(_onSwitchCamera);
    on<ToggleFlashEvent>(_onToggleFlash);
    on<SetZoomEvent>(_onSetZoom);
    on<SetExposureEvent>(_onSetExposure);
    on<ToggleGridEvent>(_onToggleGrid);
    on<SetCameraModeEvent>(_onSetCameraMode);
    on<SetFilterEvent>(_onSetFilter);
    on<TakePhotoEvent>(_onTakePhoto);
    on<StartVideoRecordingEvent>(_onStartRecording);
    on<StopVideoRecordingEvent>(_onStopRecording);
    on<DisposeStoryCameraEvent>(_onDispose);
  }

  StoryCameraService get service => _service;

  Future<void> _onInitialize(
    InitializeStoryCameraEvent event,
    Emitter<StoryCameraState> emit,
  ) async {
    emit(StoryCameraLoading());
    try {
      await _service.initialize(preferredLens: event.preferredLens);
      emit(StoryCameraReady(
        capabilities: _service.capabilities,
        currentLens: _service.currentCamera?.lensDirection ?? CameraLensDirection.back,
        flashMode: _service.currentFlashMode,
        currentZoom: _service.currentZoom,
        currentExposure: _service.currentExposure,
      ));
    } catch (e) {
      emit(StoryCameraError("Failed to initialize camera: ${e.toString()}"));
    }
  }

  Future<void> _onSwitchCamera(
    SwitchStoryCameraEvent event,
    Emitter<StoryCameraState> emit,
  ) async {
    if (state is! StoryCameraReady) return;
    final current = state as StoryCameraReady;
    emit(StoryCameraLoading());
    try {
      await _service.switchCamera();
      emit(current.copyWith(
        capabilities: _service.capabilities,
        currentLens: _service.currentCamera?.lensDirection ?? CameraLensDirection.back,
        flashMode: _service.currentFlashMode,
        currentZoom: _service.currentZoom,
        currentExposure: _service.currentExposure,
      ));
    } catch (e) {
      emit(StoryCameraError("Failed to switch camera: ${e.toString()}"));
    }
  }

  Future<void> _onToggleFlash(
    ToggleFlashEvent event,
    Emitter<StoryCameraState> emit,
  ) async {
    if (state is! StoryCameraReady) return;
    final current = state as StoryCameraReady;
    if (!current.capabilities.supportsFlash) return;

    final nextMode = current.flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _service.setFlashMode(nextMode);
    emit(current.copyWith(flashMode: nextMode));
  }

  Future<void> _onSetZoom(
    SetZoomEvent event,
    Emitter<StoryCameraState> emit,
  ) async {
    if (state is! StoryCameraReady) return;
    final current = state as StoryCameraReady;
    await _service.setZoom(event.zoom);
    emit(current.copyWith(currentZoom: _service.currentZoom));
  }

  Future<void> _onSetExposure(
    SetExposureEvent event,
    Emitter<StoryCameraState> emit,
  ) async {
    if (state is! StoryCameraReady) return;
    final current = state as StoryCameraReady;
    await _service.setExposure(event.exposure);
    emit(current.copyWith(currentExposure: _service.currentExposure));
  }

  void _onToggleGrid(
    ToggleGridEvent event,
    Emitter<StoryCameraState> emit,
  ) {
    if (state is! StoryCameraReady) return;
    final current = state as StoryCameraReady;
    emit(current.copyWith(gridEnabled: !current.gridEnabled));
  }

  void _onSetCameraMode(
    SetCameraModeEvent event,
    Emitter<StoryCameraState> emit,
  ) {
    if (state is! StoryCameraReady) return;
    final current = state as StoryCameraReady;
    emit(current.copyWith(selectedMode: event.mode));
  }

  void _onSetFilter(
    SetFilterEvent event,
    Emitter<StoryCameraState> emit,
  ) {
    if (state is! StoryCameraReady) return;
    final current = state as StoryCameraReady;
    emit(current.copyWith(selectedFilter: event.filter));
  }

  Future<void> _onTakePhoto(
    TakePhotoEvent event,
    Emitter<StoryCameraState> emit,
  ) async {
    if (state is! StoryCameraReady) return;
    final file = await _service.takePhoto();
    if (file != null) {
      emit(StoryCameraMediaCaptured(mediaPath: file.path, mediaType: 'IMAGE'));
    } else {
      emit(const StoryCameraError("Failed to capture photo."));
    }
  }

  Future<void> _onStartRecording(
    StartVideoRecordingEvent event,
    Emitter<StoryCameraState> emit,
  ) async {
    if (state is! StoryCameraReady) return;
    final current = state as StoryCameraReady;
    final success = await _service.startRecording();
    if (success) {
      _recordingTimer?.cancel();
      int seconds = 0;
      emit(current.copyWith(isRecording: true, recordingSeconds: seconds));
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        seconds++;
        add(StopVideoRecordingEvent()); // Trigger check or update
      });
    }
  }

  Future<void> _onStopRecording(
    StopVideoRecordingEvent event,
    Emitter<StoryCameraState> emit,
  ) async {
    _recordingTimer?.cancel();
    if (state is StoryCameraReady && (state as StoryCameraReady).isRecording) {
      final file = await _service.stopRecording();
      if (file != null) {
        emit(StoryCameraMediaCaptured(mediaPath: file.path, mediaType: 'VIDEO'));
      } else {
        emit(const StoryCameraError("Failed to record video."));
      }
    }
  }

  Future<void> _onDispose(
    DisposeStoryCameraEvent event,
    Emitter<StoryCameraState> emit,
  ) async {
    _recordingTimer?.cancel();
    await _service.dispose();
    emit(StoryCameraInitial());
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _service.dispose();
    return super.close();
  }
}
