import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Lets the user speak their prompt instead of typing it, in whichever
/// language they've selected in Settings (see [AppLanguage.speechLocale]).
class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return false;
    _initialized = await _speech.initialize(
      onError: (e) => debugPrint("Speech error: ${e.errorMsg}"),
      onStatus: (s) => debugPrint("Speech status: $s"),
    );
    return _initialized;
  }

  bool get isListening => _speech.isListening;

  /// Starts listening in [speechLocale] (e.g. "km_KH", "en_US") and calls
  /// [onResult] with the live/final transcript.
  Future<bool> startListening({
    required String speechLocale,
    required void Function(String text) onResult,
  }) async {
    final ok = await _ensureInitialized();
    if (!ok) return false;

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenOptions: stt.SpeechListenOptions(
        localeId: speechLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      ),
    );
    return true;
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Returns true if this device actually supports the requested locale,
  /// so the UI can warn the user instead of silently failing.
  Future<bool> isLocaleSupported(String speechLocale) async {
    final ok = await _ensureInitialized();
    if (!ok) return false;
    final locales = await _speech.locales();
    return locales.any((l) => l.localeId.replaceAll("-", "_") == speechLocale);
  }
}
