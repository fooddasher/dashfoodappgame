import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerData extends ChangeNotifier {
  static const String _keyTotalCoins = 'total_coins';
  static const String _keyUnlockedLevels = 'unlocked_levels';
  static const String _keyEquippedColor = 'equipped_color';
  static const String _keyPrefixHighScore = 'high_score_level_';
  static const String _keyTutorialShown = 'tutorial_shown';

  int _totalCoins = 0;
  int _unlockedLevels = 1;
  int _equippedColor = 0xFFFF9000; // Default Dash Orange
  bool _tutorialShown = false;

  // Map of level ID to high score (stars/points)
  // For now, let's store points. Stars can be calculated.
  final Map<int, int> _highScores = {};

  int get totalCoins => _totalCoins;
  int get unlockedLevels => _unlockedLevels;
  int get equippedColor => _equippedColor;
  bool get tutorialShown => _tutorialShown;

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    _totalCoins = _prefs.getInt(_keyTotalCoins) ?? 0;
    _unlockedLevels = _prefs.getInt(_keyUnlockedLevels) ?? 1;
    _equippedColor = _prefs.getInt(_keyEquippedColor) ?? 0xFFFF9000;
    _tutorialShown = _prefs.getBool(_keyTutorialShown) ?? false;

    // Load high scores (assume we check for levels 1 to 30)
    for (int i = 1; i <= 30; i++) {
      final score = _prefs.getInt('$_keyPrefixHighScore$i');
      if (score != null) {
        _highScores[i] = score;
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  int getHighScore(int levelId) {
    return _highScores[levelId] ?? 0;
  }

  Future<void> addCoins(int amount) async {
    _totalCoins += amount;
    await _prefs.setInt(_keyTotalCoins, _totalCoins);
    notifyListeners();
  }

  Future<void> unlockLevel(int levelId) async {
    if (levelId > _unlockedLevels) {
      _unlockedLevels = levelId;
      await _prefs.setInt(_keyUnlockedLevels, _unlockedLevels);
      notifyListeners();
    }
  }

  Future<void> setEquippedColor(int colorValue) async {
    _equippedColor = colorValue;
    await _prefs.setInt(_keyEquippedColor, _equippedColor);
    notifyListeners();
  }

  Future<void> markTutorialShown() async {
    _tutorialShown = true;
    await _prefs.setBool(_keyTutorialShown, _tutorialShown);
    notifyListeners();
  }

  Future<void> updateHighScore(int levelId, int score) async {
    final currentHigh = _highScores[levelId] ?? 0;
    if (score > currentHigh) {
      _highScores[levelId] = score;
      await _prefs.setInt('$_keyPrefixHighScore$levelId', score);
      notifyListeners();
    }
  }

  /// Resets all data (for debugging or settings)
  Future<void> resetData() async {
    await _prefs.clear();
    _totalCoins = 0;
    _unlockedLevels = 1;
    _equippedColor = 0xFFFF9000;
    _tutorialShown = false;
    _highScores.clear();
    notifyListeners();
  }
}

