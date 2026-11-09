import 'dart:convert';
import 'dart:io';

import 'package:background_hiit_timer/utils/log.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key: global on/off switch for spoken announcements.
const String voiceAnnouncementsPrefKey = 'voiceAnnouncements';

/// SharedPreferences key: JSON written by the app before a workout starts:
/// `{"workoutId": "<timer id>", "texts": {"<interval index>": "<text>"}}`
const String voiceAnnouncementTextsPrefKey = 'voiceAnnouncementTexts';

/// Speaks announcements from the background service isolate, so they keep
/// working with the screen locked or the app in the background (the same
/// place where the timer sounds are played).
class ServiceVoice {
  final FlutterTts _tts = FlutterTts();
  final String workoutId;
  bool _ready = false;
  int _lastIndex = -1;

  ServiceVoice(this.workoutId);

  Future<void> init() async {
    try {
      await _tts.setLanguage('es-ES');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false);
      _ready = true;
    } catch (e) {
      logger.e('Voice init failed: $e');
      return;
    }

    if (Platform.isAndroid) {
      // Same audio type as GPS navigation prompts, so it plays over music.
      try {
        await _tts.setAudioAttributesForNavigation();
      } catch (e) {
        logger.w('Navigation audio attributes not applied: $e');
      }
    }
    if (Platform.isIOS) {
      try {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.duckOthers,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
      } catch (e) {
        logger.w('iOS audio category not applied: $e');
      }
    }
  }

  /// Texts for this workout, or null if the app has not written them yet.
  Map<String, dynamic>? _texts(SharedPreferences preferences) {
    final String? raw = preferences.getString(voiceAnnouncementTextsPrefKey);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['workoutId'] != workoutId) return null;
      return data['texts'] as Map<String, dynamic>;
    } catch (e) {
      logger.e('Invalid voice announcement data: $e');
      return null;
    }
  }

  /// Call on every timer tick. Speaks once each time the interval changes.
  void onTick(int intervalIndex, bool paused, SharedPreferences preferences) {
    if (!_ready || intervalIndex == _lastIndex) return;

    final texts = _texts(preferences);
    // Texts not available yet: retry on the next tick.
    if (texts == null) return;
    _lastIndex = intervalIndex;

    if (paused) return;
    if (!(preferences.getBool(voiceAnnouncementsPrefKey) ?? true)) return;

    final Object? text = texts['$intervalIndex'];
    if (text is! String || text.isEmpty) return;

    _speak(text, preferences);
  }

  Future<void> _speak(String text, SharedPreferences preferences) async {
    try {
      final double volume = preferences.getDouble('volume') ?? 80;
      await _tts.setVolume((volume / 100).clamp(0.0, 1.0));
      // focus: on Android, other apps (Spotify, ...) lower their volume
      // while the announcement plays, and restore it afterwards.
      await _tts.speak(text, focus: true);
    } catch (e) {
      logger.e('Voice announcement failed: $e');
    }
  }
}
