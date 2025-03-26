import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isMuted = false;

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBackgroundMusic() async {
    if (!isPlaying) {
      await _audioPlayer.play(AssetSource('music/tama1.mp3'));
      isPlaying = true;
    }
  }

  void stopMusic() {
    _audioPlayer.stop();
    isPlaying = false;
  }

  void toggleMute() {
    isMuted = !isMuted;
    _audioPlayer.setVolume(isMuted ? 0.0 : 1.0);
  }
}
