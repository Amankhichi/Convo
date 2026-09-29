import 'dart:async';
import 'dart:developer' as developer;
import 'package:audio_session/audio_session.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:convo/features/calling/domain/entities/ice_server.dart';

typedef OnIceCandidateCallback = void Function(RTCIceCandidate candidate);
typedef OnConnectionStateCallback = void Function(RTCPeerConnectionState state);
typedef OnIceConnectionStateCallback = void Function(RTCIceConnectionState state);

class WebRtcService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  MediaStreamTrack? _localAudioTrack;

  bool _isAudioMuted = false;
  bool _isSpeakerOn = false;
  bool _remoteDescriptionSet = false;

  final List<RTCIceCandidate> _queuedRemoteCandidates = [];

  OnIceCandidateCallback? onIceCandidate;
  OnConnectionStateCallback? onConnectionStateChanged;
  OnIceConnectionStateCallback? onIceConnectionStateChanged;
  void Function(MediaStream stream)? onRemoteStreamAdded;

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isMuted => _isAudioMuted;
  bool get isSpeakerOn => _isSpeakerOn;

  Future<bool> checkAndRequestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    if (result.isGranted) return true;

    _log("Microphone permission denied: $result");
    return false;
  }

  Future<void> initializePeerConnection(List<IceServerEntity> iceServers, {String roleTag = '[WEBRTC-DEBUG]'}) async {
    await dispose(); // Ensure clean slate before initializing

    final hasPermission = await checkAndRequestMicrophonePermission();
    if (!hasPermission) {
      _log("$roleTag Microphone permission DENIED");
      throw Exception("Microphone permission is required to make a voice call");
    }
    _log("$roleTag Microphone permission GRANTED");

    await _configureAudioSession(roleTag: roleTag);

    final formattedIceServers = iceServers.isNotEmpty
        ? iceServers.map((s) => s.toMap()).toList()
        : [
            {
              'urls': [
                'stun:stun.l.google.com:19302',
                'stun:stun1.l.google.com:19302',
                'stun:stun2.l.google.com:19302',
                'stun:stun3.l.google.com:19302',
                'stun:stun4.l.google.com:19302',
              ],
            }
          ];

    final configuration = {
      'iceServers': formattedIceServers,
      'sdpSemantics': 'unified-plan',
    };

    final constraints = {
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    _log("$roleTag createPeerConnection START");
    _log("$roleTag Creating RTCPeerConnection with iceServers count: ${formattedIceServers.length}");
    _peerConnection = await createPeerConnection(configuration, constraints);
    _log("$roleTag createPeerConnection SUCCESS");
    _log("$roleTag PEER_CONNECTION_CREATED");

    // Setup Listeners
    _peerConnection!.onIceCandidate = (candidate) {
      _log("$roleTag ICE_CANDIDATE_CREATED candidate=${candidate.candidate}");
      if (onIceCandidate != null) {
        onIceCandidate!(candidate);
      }
    };

    _peerConnection!.onConnectionState = (state) {
      _log("$roleTag PEER_CONNECTION_STATE=${state.name.toUpperCase()}");
      if (onConnectionStateChanged != null) {
        onConnectionStateChanged!(state);
      }
    };

    _peerConnection!.onIceConnectionState = (state) {
      _log("$roleTag ICE_CONNECTION_STATE=${state.name.toUpperCase()}");
      if (onIceConnectionStateChanged != null) {
        onIceConnectionStateChanged!(state);
      }
    };

    _peerConnection!.onTrack = (event) async {
      _log("$roleTag REMOTE_AUDIO_TRACK_RECEIVED kind=${event.track.kind}, id=${event.track.id}, enabled=${event.track.enabled}");
      if (event.track.kind == 'audio') {
        event.track.enabled = true;
      }
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
      } else {
        _remoteStream ??= await createLocalMediaStream('remote_stream_${DateTime.now().millisecondsSinceEpoch}');
        await _remoteStream!.addTrack(event.track);
      }
      try {
        await Helper.setSpeakerphoneOn(_isSpeakerOn);
        _log("$roleTag Audio output route initialized speakerphone=$_isSpeakerOn");
      } catch (e) {
        _log("$roleTag Error enabling audio route: $e");
      }
      if (onRemoteStreamAdded != null && _remoteStream != null) {
        onRemoteStreamAdded!(_remoteStream!);
      }
    };

    _peerConnection!.onAddStream = (stream) {
      _log("$roleTag Remote stream added via legacy listener");
      _remoteStream = stream;
      if (onRemoteStreamAdded != null) {
        onRemoteStreamAdded!(stream);
      }
    };

    // Get User Media for Audio Only
    final mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    };

    _log("$roleTag getUserMedia START acquiring user media audio stream...");
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _log("$roleTag getUserMedia SUCCESS");

    final audioTracks = _localStream!.getAudioTracks();
    if (audioTracks.isNotEmpty) {
      _localAudioTrack = audioTracks.first;
      _localAudioTrack!.enabled = true;
      _log("$roleTag Local audio track enabled=true muted=${!_localAudioTrack!.enabled}");
    }

    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }
    _log("$roleTag LOCAL_AUDIO_TRACK_ADDED count=${_localStream!.getAudioTracks().length}");

    try {
      await Helper.setSpeakerphoneOn(_isSpeakerOn);
    } catch (e) {
      _log("$roleTag Error setting initial speakerphone state: $e");
    }
  }

  Future<RTCSessionDescription> createOffer({String roleTag = '[WEBRTC-DEBUG][A]'}) async {
    if (_peerConnection == null) {
      throw Exception("PeerConnection not initialized");
    }

    final offerConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    };

    _log("$roleTag createOffer START");
    final offer = await _peerConnection!.createOffer(offerConstraints);
    _log("$roleTag createOffer SUCCESS");
    _log("$roleTag setLocalDescription START");
    await _peerConnection!.setLocalDescription(offer);
    _log("$roleTag setLocalDescription SUCCESS");
    _log("$roleTag SDP_OFFER_CREATED");
    return offer;
  }

  Future<RTCSessionDescription> handleOfferAndCreateAnswer(String offerSdp, {String roleTag = '[WEBRTC-DEBUG][B]'}) async {
    if (_peerConnection == null) {
      throw Exception("PeerConnection not initialized");
    }

    _log("$roleTag SDP_OFFER_RECEIVED");
    final offer = RTCSessionDescription(offerSdp, 'offer');
    _log("$roleTag setRemoteDescription START");
    await _peerConnection!.setRemoteDescription(offer);
    _remoteDescriptionSet = true;
    _log("$roleTag setRemoteDescription SUCCESS");
    _log("$roleTag REMOTE_DESCRIPTION_SET");

    await _flushQueuedCandidates(roleTag: roleTag);

    final answerConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    };

    _log("$roleTag createAnswer START");
    final answer = await _peerConnection!.createAnswer(answerConstraints);
    _log("$roleTag createAnswer SUCCESS");
    _log("$roleTag setLocalDescription START");
    await _peerConnection!.setLocalDescription(answer);
    _log("$roleTag setLocalDescription SUCCESS");
    _log("$roleTag SDP_ANSWER_CREATED");
    return answer;
  }

  Future<void> handleAnswer(String answerSdp, {String roleTag = '[WEBRTC-DEBUG][A]'}) async {
    if (_peerConnection == null) return;
    _log("$roleTag SDP_ANSWER_RECEIVED");
    final answer = RTCSessionDescription(answerSdp, 'answer');
    _log("$roleTag setRemoteDescription START");
    await _peerConnection!.setRemoteDescription(answer);
    _remoteDescriptionSet = true;
    _log("$roleTag setRemoteDescription SUCCESS");
    _log("$roleTag REMOTE_DESCRIPTION_SET");
    await _flushQueuedCandidates(roleTag: roleTag);
  }

  Future<void> addRemoteIceCandidate(Map<String, dynamic> candidateMap, {String roleTag = '[WEBRTC-DEBUG]'}) async {
    String? candidateStr;
    String? sdpMid;
    int sdpMLineIndex = 0;

    final rawCandidate = candidateMap['candidate'] ?? candidateMap['iceCandidate'] ?? candidateMap['ice'];

    if (rawCandidate is Map) {
      final map = Map<String, dynamic>.from(rawCandidate);
      candidateStr = map['candidate']?.toString() ?? map['iceCandidate']?.toString();
      sdpMid = map['sdpMid']?.toString();
      sdpMLineIndex = map['sdpMLineIndex'] is int
          ? map['sdpMLineIndex'] as int
          : int.tryParse(map['sdpMLineIndex']?.toString() ?? '0') ?? 0;
    } else if (rawCandidate != null) {
      candidateStr = rawCandidate.toString();
      sdpMid = candidateMap['sdpMid']?.toString();
      sdpMLineIndex = candidateMap['sdpMLineIndex'] is int
          ? candidateMap['sdpMLineIndex'] as int
          : int.tryParse(candidateMap['sdpMLineIndex']?.toString() ?? '0') ?? 0;
    }

    if (candidateStr == null || candidateStr.trim().isEmpty) {
      _log("$roleTag Ignoring empty ICE candidate payload");
      return;
    }

    final candidate = RTCIceCandidate(candidateStr, sdpMid, sdpMLineIndex);

    if (_peerConnection != null && _remoteDescriptionSet) {
      _log("$roleTag ICE_CANDIDATE_RECEIVED candidate=${candidate.candidate}");
      try {
        await _peerConnection!.addCandidate(candidate);
        _log("$roleTag addCandidate SUCCESS");
      } catch (e) {
        _log("$roleTag addCandidate FAILED: $e");
      }
    } else {
      _log("$roleTag Remote description not set yet. Queuing remote ICE candidate.");
      _queuedRemoteCandidates.add(candidate);
    }
  }

  Future<void> _flushQueuedCandidates({String roleTag = '[WEBRTC-DEBUG]'}) async {
    if (_peerConnection == null || !_remoteDescriptionSet) return;
    _log("$roleTag Flushing ${_queuedRemoteCandidates.length} queued ICE candidates");
    for (final candidate in _queuedRemoteCandidates) {
      try {
        _log("$roleTag Adding queued ICE candidate: ${candidate.candidate}");
        await _peerConnection!.addCandidate(candidate);
        _log("$roleTag addCandidate SUCCESS");
      } catch (e) {
        _log("$roleTag addCandidate FAILED: $e");
      }
    }
    _queuedRemoteCandidates.clear();
  }

  void setMute(bool mute) {
    _isAudioMuted = mute;
    if (_localAudioTrack != null) {
      _localAudioTrack!.enabled = !mute;
      _log("[WEBRTC-DEBUG] Local audio track muted: $mute");
    }
  }

  Future<void> setSpeakerphoneOn(bool enable) async {
    _isSpeakerOn = enable;
    try {
      await Helper.setSpeakerphoneOn(enable);
      _log("[WEBRTC-DEBUG] Speakerphone set to: $enable");
    } catch (e) {
      _log("[WEBRTC-DEBUG] Error setting speakerphone: $e");
    }
  }

  Future<void> dispose() async {
    _log("Disposing WebRtcService...");
    _remoteDescriptionSet = false;
    _queuedRemoteCandidates.clear();

    if (_localAudioTrack != null) {
      _localAudioTrack!.enabled = false;
      _localAudioTrack = null;
    }

    if (_localStream != null) {
      try {
        _localStream!.getTracks().forEach((track) {
          track.stop();
        });
        await _localStream!.dispose();
      } catch (_) {}
      _localStream = null;
    }

    if (_remoteStream != null) {
      try {
        _remoteStream!.getTracks().forEach((track) {
          track.stop();
        });
        await _remoteStream!.dispose();
      } catch (_) {}
      _remoteStream = null;
    }

    if (_peerConnection != null) {
      try {
        await _peerConnection!.close();
        await _peerConnection!.dispose();
      } catch (_) {}
      _peerConnection = null;
    }

    onIceCandidate = null;
    onConnectionStateChanged = null;
    onIceConnectionStateChanged = null;
    onRemoteStreamAdded = null;

    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (_) {}
  }

  Future<void> _configureAudioSession({String roleTag = '[WEBRTC-DEBUG]'}) async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      await session.setActive(true);
      _log("$roleTag AudioSession configured and activated for voiceChat");
    } catch (e) {
      _log("$roleTag AudioSession configuration error: $e");
    }
  }

  void _log(String message) {
    developer.log("[WebRtcService] $message");
  }
}
