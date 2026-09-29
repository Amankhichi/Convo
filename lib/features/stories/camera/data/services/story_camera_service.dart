import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCapabilities {
  final bool hasFrontCamera;
  final bool hasBackCamera;
  final bool supportsFlash;
  final bool supportsZoom;
  final bool supportsExposure;
  final double minZoom;
  final double maxZoom;
  final double minExposure;
  final double maxExposure;

  const CameraCapabilities({
    this.hasFrontCamera = false,
    this.hasBackCamera = false,
    this.supportsFlash = false,
    this.supportsZoom = false,
    this.supportsExposure = false,
    this.minZoom = 1.0,
    this.maxZoom = 1.0,
    this.minExposure = 0.0,
    this.maxExposure = 0.0,
  });
}

class StoryCameraService {
  CameraController? _controller;
  List<CameraDescription> _availableCameras = [];
  CameraDescription? _currentCamera;
  CameraCapabilities _capabilities = const CameraCapabilities();

  FlashMode _currentFlashMode = FlashMode.off;
  double _currentZoom = 1.0;
  double _currentExposure = 0.0;
  bool _isRecording = false;

  CameraController? get controller => _controller;
  CameraDescription? get currentCamera => _currentCamera;
  CameraCapabilities get capabilities => _capabilities;
  FlashMode get currentFlashMode => _currentFlashMode;
  double get currentZoom => _currentZoom;
  double get currentExposure => _currentExposure;
  bool get isRecording => _isRecording;
  bool get isInitialized => _controller != null && _controller!.value.isInitialized;

  Future<void> initialize({CameraLensDirection preferredLens = CameraLensDirection.back}) async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        throw Exception("No cameras available on device");
      }

      final hasBack = _availableCameras.any((c) => c.lensDirection == CameraLensDirection.back);
      final hasFront = _availableCameras.any((c) => c.lensDirection == CameraLensDirection.front);

      _currentCamera = _availableCameras.firstWhere(
        (c) => c.lensDirection == preferredLens,
        orElse: () => _availableCameras.first,
      );

      await _initControllerWithFallback(_currentCamera!);

      // Calculate capabilities
      double minZ = 1.0;
      double maxZ = 1.0;
      bool zoomSupp = false;
      try {
        minZ = await _controller!.getMinZoomLevel();
        maxZ = await _controller!.getMaxZoomLevel();
        zoomSupp = maxZ > minZ;
      } catch (_) {}

      double minExp = 0.0;
      double maxExp = 0.0;
      bool expSupp = false;
      try {
        minExp = await _controller!.getMinExposureOffset();
        maxExp = await _controller!.getMaxExposureOffset();
        expSupp = maxExp > minExp;
      } catch (_) {}

      bool flashSupp = false;
      try {
        await _controller!.setFlashMode(FlashMode.off);
        flashSupp = true;
      } catch (_) {
        flashSupp = false;
      }

      _capabilities = CameraCapabilities(
        hasFrontCamera: hasFront,
        hasBackCamera: hasBack,
        supportsFlash: flashSupp,
        supportsZoom: zoomSupp,
        supportsExposure: expSupp,
        minZoom: minZ,
        maxZoom: maxZ,
        minExposure: minExp,
        maxExposure: maxExp,
      );

      _currentZoom = minZ;
      _currentExposure = 0.0;
    } catch (e) {
      debugPrint("[StoryCameraService] Init failed: $e");
      rethrow;
    }
  }

  Future<void> _initControllerWithFallback(CameraDescription description) async {
    await _controller?.dispose();

    const presets = [
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    ];

    for (final preset in presets) {
      try {
        final ctrl = CameraController(
          description,
          preset,
          enableAudio: true,
          imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.jpeg,
        );
        await ctrl.initialize();
        _controller = ctrl;
        return;
      } catch (e) {
        debugPrint("[StoryCameraService] Failed preset $preset: $e");
      }
    }

    throw Exception("Could not initialize camera with any supported resolution preset");
  }

  Future<void> switchCamera() async {
    if (_availableCameras.length <= 1 || _currentCamera == null) return;

    final targetDirection = _currentCamera!.lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    final targetCamera = _availableCameras.firstWhere(
      (c) => c.lensDirection == targetDirection,
      orElse: () => _availableCameras.first,
    );

    _currentCamera = targetCamera;
    await _initControllerWithFallback(targetCamera);
  }

  Future<void> setZoom(double zoom) async {
    if (!isInitialized || !_capabilities.supportsZoom) return;
    final clamped = zoom.clamp(_capabilities.minZoom, _capabilities.maxZoom);
    try {
      await _controller!.setZoomLevel(clamped);
      _currentZoom = clamped;
    } catch (_) {}
  }

  Future<void> setExposure(double exposure) async {
    if (!isInitialized || !_capabilities.supportsExposure) return;
    final clamped = exposure.clamp(_capabilities.minExposure, _capabilities.maxExposure);
    try {
      await _controller!.setExposureOffset(clamped);
      _currentExposure = clamped;
    } catch (_) {}
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (!isInitialized || !_capabilities.supportsFlash) return;
    try {
      await _controller!.setFlashMode(mode);
      _currentFlashMode = mode;
    } catch (_) {}
  }

  Future<void> setFocusPoint(Offset point) async {
    if (!isInitialized) return;
    try {
      await _controller!.setFocusPoint(point);
    } catch (_) {}
  }

  Future<XFile?> takePhoto() async {
    if (!isInitialized) return null;
    try {
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint("[StoryCameraService] takePhoto failed: $e");
      return null;
    }
  }

  Future<bool> startRecording() async {
    if (!isInitialized || _isRecording) return false;
    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
      return true;
    } catch (e) {
      debugPrint("[StoryCameraService] startRecording failed: $e");
      return false;
    }
  }

  Future<XFile?> stopRecording() async {
    if (!isInitialized || !_isRecording) return null;
    try {
      final file = await _controller!.stopVideoRecording();
      _isRecording = false;
      return file;
    } catch (e) {
      debugPrint("[StoryCameraService] stopRecording failed: $e");
      _isRecording = false;
      return null;
    }
  }

  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await _controller?.stopVideoRecording();
        _isRecording = false;
      }
      await _controller?.dispose();
      _controller = null;
    } catch (_) {}
  }
}
