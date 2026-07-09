import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'notification_service.dart';

class AdhanAudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  static String currentPrayerName = '';

  /// Check if adhan is currently playing
  static bool get isPlaying => isPlayingNotifier.value;

  /// Play adhan sound from asset
  static Future<void> playAdhan(String prayerName) async {
    try {
      if (isPlaying) {
        await stopAdhan();
      }
      currentPrayerName = prayerName;
      isPlayingNotifier.value = true;
      await _audioPlayer.play(AssetSource('audio/adhan.mp3'));
      
      // Auto-stop notifier on completion
      _audioPlayer.onPlayerComplete.listen((_) {
        isPlayingNotifier.value = false;
      });
    } catch (e) {
      isPlayingNotifier.value = false;
    }
  }

  /// Stop adhan sound and cancel background notifications
  static Future<void> stopAdhan() async {
    try {
      await _audioPlayer.stop();
      isPlayingNotifier.value = false;
      
      // Cancel active adhan notification sound
      await NotificationService.cancelAdhanNotification();
    } catch (_) {
      isPlayingNotifier.value = false;
    }
  }

  /// Set volume (0.0 to 1.0)
  static Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  /// Dispose the audio player
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
