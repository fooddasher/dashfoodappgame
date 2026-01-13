import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager extends Component {
  bool _bgmPlaying = false;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keySfxEnabled = 'sfx_enabled';
  
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  @override
  Future<void> onLoad() async {
    // Load saved preferences
    final prefs = await SharedPreferences.getInstance();
    _musicEnabled = prefs.getBool(_keyMusicEnabled) ?? true;
    _sfxEnabled = prefs.getBool(_keySfxEnabled) ?? true;
    
    // Preload audio files (removed scooter_engine_loop, using menu_sound for all BGM)
    await FlameAudio.audioCache.loadAll([
      'carton_thud.mp3',
      'deliery_success.mp3',
      'game_over.mp3',
      'menu_sound.mp3',
      'pickup_chime.mp3',
      'timer_warning.mp3',
    ]);
  }

  void playBgm() {
    if (!_bgmPlaying && _musicEnabled) {
      FlameAudio.bgm.play('menu_sound.mp3', volume: 0.4);
      _bgmPlaying = true;
    }
  }

  void stopBgm() {
    FlameAudio.bgm.stop();
    _bgmPlaying = false;
  }

  void pauseBgm() {
    FlameAudio.bgm.pause();
  }

  void resumeBgm() {
    if (_musicEnabled) {
      FlameAudio.bgm.resume();
    }
  }

  void playSfx(String fileName, {double volume = 1.0}) {
    if (_sfxEnabled) {
      FlameAudio.play(fileName, volume: volume);
    }
  }
  
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMusicEnabled, enabled);
    
    if (enabled) {
      if (_bgmPlaying) {
        FlameAudio.bgm.resume();
      }
    } else {
      FlameAudio.bgm.pause();
    }
  }
  
  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySfxEnabled, enabled);
  }
}

