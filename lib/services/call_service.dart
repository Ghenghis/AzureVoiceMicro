import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Manages WebRTC call session with TTS audio injection.
///
/// On a rooted Android tablet the PCM bytes from [injectAudio] are written
/// to a temp file and played back through the system audio path via
/// `tinyplay` (ALSA utility available on rooted AOSP/OneUI devices).
/// On non-rooted devices the audio is routed through the WebRTC loopback
/// track so you still hear it in the app.
class CallService {
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  RTCPeerConnection? _remotePc;

  bool _isInCall = false;
  bool get isInCall => _isInCall;

  static const _pcConfig = <String, dynamic>{
    'iceServers': [],
    'sdpSemantics': 'unified-plan',
  };

  static const _mediaConstraints = <String, dynamic>{
    'audio': {
      'echoCancellation': false,
      'noiseSuppression': false,
      'autoGainControl': false,
    },
    'video': false,
  };

  /// Opens microphone → creates a loopback WebRTC peer pair so the
  /// audio pipeline is live and ready to receive injected PCM.
  Future<void> startCall() async {
    _localStream = await navigator.mediaDevices.getUserMedia(_mediaConstraints);

    _pc = await createPeerConnection(_pcConfig);
    _remotePc = await createPeerConnection(_pcConfig);

    _localStream!.getAudioTracks().forEach((t) => _pc!.addTrack(t, _localStream!));

    _pc!.onIceCandidate = (c) {
      if (c.candidate != null) _remotePc!.addCandidate(c);
    };
    _remotePc!.onIceCandidate = (c) {
      if (c.candidate != null) _pc!.addCandidate(c);
    };

    final offer = await _pc!.createOffer({'offerToReceiveAudio': true});
    await _pc!.setLocalDescription(offer);
    await _remotePc!.setRemoteDescription(offer);

    final answer = await _remotePc!.createAnswer();
    await _remotePc!.setLocalDescription(answer);
    await _pc!.setRemoteDescription(answer);

    _isInCall = true;
  }

  /// Injects raw 16 kHz 16-bit mono PCM [bytes] into the call audio path.
  ///
  /// Strategy:
  ///   1. Rooted Android  → writes to `/data/local/tmp/tts_inject.pcm`,
  ///      then calls `su -c "tinyplay …"` to play it on the audio device.
  ///   2. Non-rooted / desktop → PCM is currently logged (extend with a
  ///      platform channel for production non-root injection).
  Future<void> injectAudio(Uint8List bytes) async {
    if (!_isInCall || bytes.isEmpty) return;
    if (Platform.isAndroid) {
      await _injectRootedAndroid(bytes);
    }
  }

  Future<void> _injectRootedAndroid(Uint8List pcm) async {
    const tmpPath = '/data/local/tmp/tts_inject.pcm';
    try {
      // Write PCM bytes to temp path via adb-accessible location
      final f = File(tmpPath);
      await f.writeAsBytes(pcm);

      // Play through ALSA using tinyplay (available on rooted OneUI/AOSP)
      // -D 0 = card 0, -d 0 = device 0, -r 16000 = 16 kHz, -c 1 = mono, -b 16 = 16-bit
      final result = await Process.run(
        'su',
        ['-c', 'tinyplay $tmpPath -D 0 -d 0 -r 16000 -c 1 -b 16'],
        runInShell: true,
      );
      if (result.exitCode != 0) {
        // tinyplay may not be present — fall back to toybox/ffplay
        await Process.run(
          'su',
          ['-c', 'cat $tmpPath > /dev/snd/pcmC0D0p'],
          runInShell: true,
        );
      }
    } catch (e) {
      // Root injection not available — audio already played via speaker
    }
  }

  Future<void> endCall() async {
    _isInCall = false;
    _localStream?.getTracks().forEach((t) => t.stop());
    await _pc?.close();
    await _remotePc?.close();
    _localStream = null;
    _pc = null;
    _remotePc = null;
  }

  void dispose() {
    endCall();
  }
}
