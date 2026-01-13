import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'food_dash_game.dart';
import '../utils/constants.dart';

/// Manages game state, scoring, and level progression
class GameManager extends Component with HasGameReference<FoodDashGame> {
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<double> timeRemaining = ValueNotifier(60.0);
  final ValueNotifier<int> currentLevel = ValueNotifier(1);
  
  bool isGameOver = false;
  int _targetScore = 50; // Score needed to complete level
  int _deliveriesCompleted = 0;

  @override
  Future<void> onLoad() async {
    // Initialize with level 1 settings
    _setupLevel(1);
  }

  /// Setup level parameters with progressive difficulty
  /// Key design: Levels 1-2 are introductory, Level 3+ introduces real challenge
  void _setupLevel(int level) {
    currentLevel.value = level;
    
    final bool isIntroLevel = level <= 2;
    
    // Calculate target score with tier-based progression
    // Intro (1-2): 100-130 (easy learning), Levels 3-5: 160-210
    // Medium (6-15): 230-450, Hard (16-25): 450-650, Expert (26-30): 650-775
    if (isIntroLevel) {
      _targetScore = 100 + (level - 1) * 30;
    } else if (level <= GameConstants.easyLevelCap) {
      _targetScore = 160 + (level - 3) * 25;
    } else if (level <= GameConstants.mediumLevelCap) {
      final levelInTier = level - GameConstants.easyLevelCap;
      _targetScore = 230 + levelInTier * 22;
    } else if (level <= GameConstants.hardLevelCap) {
      final levelInTier = level - GameConstants.mediumLevelCap;
      _targetScore = 450 + levelInTier * 20;
    } else {
      final levelInTier = level - GameConstants.hardLevelCap;
      _targetScore = 650 + levelInTier * 25;
    }
    
    // Calculate time (balanced with increased obstacle difficulty from Level 3)
    // Intro: 40s (short intro), Levels 3-5: 50s, Medium: 55s, Hard: 60s, Expert: 55s
    double levelTime;
    if (isIntroLevel) {
      levelTime = 40.0;
    } else if (level <= GameConstants.easyLevelCap) {
      levelTime = 50.0;
    } else if (level <= GameConstants.mediumLevelCap) {
      levelTime = 55.0;
    } else if (level <= GameConstants.hardLevelCap) {
      levelTime = 60.0;
    } else {
      levelTime = 55.0;
    }
    timeRemaining.value = levelTime;
    
    // Reset state
    score.value = 0;
    _deliveriesCompleted = 0;
    isGameOver = false;
    
    final difficultyLabel = isIntroLevel ? "Intro" : "Challenge";
    debugPrint('Level $level setup ($difficultyLabel): Target=$_targetScore, Time=${levelTime}s');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.isPaused || game.isGameOver) return;

    // Timer countdown
    timeRemaining.value -= dt;
    
    // Warning sound at 10 seconds
    if (timeRemaining.value <= 10.0 && timeRemaining.value + dt > 10.0) {
      game.audioManager.playSfx('timer_warning.mp3');
    }
    
    // Time's up
    if (timeRemaining.value <= 0) {
      timeRemaining.value = 0;
      _checkGameEnd();
    }
  }
  
  void _checkGameEnd() {
    if (score.value >= _targetScore) {
      // Level complete!
      _levelComplete();
    } else {
      // Game over
      game.gameOver();
    }
  }

  /// Add score for collecting food
  void addScore(int points) {
    score.value += points;
    _deliveriesCompleted++;
    
    // Check if target reached before time runs out
    if (score.value >= _targetScore) {
      _levelComplete();
    }
  }
  
  /// Deduct score for hitting obstacles
  void deductScore(int points) {
    score.value = (score.value - points).clamp(0, 9999);
  }
  
  /// Deduct time as penalty for hitting obstacles
  void deductTime(double seconds) {
    timeRemaining.value = (timeRemaining.value - seconds).clamp(0.0, 9999.0);
    
    // Check if time ran out due to penalty
    if (timeRemaining.value <= 0) {
      _checkGameEnd();
    }
  }
  
  void _levelComplete() {
    // Calculate stars
    final stars = _calculateStars();
    
    // Award coins
    final coins = _calculateCoins(stars);
    game.playerData.addCoins(coins);
    
    // Unlock next level
    final nextLevel = currentLevel.value + 1;
    if (nextLevel <= 30) {
      game.playerData.unlockLevel(nextLevel);
    }
    
    game.levelComplete(stars, coins);
  }
  
  int _calculateStars() {
    final ratio = score.value / _targetScore;
    if (ratio >= 1.5) return 3;
    if (ratio >= 1.2) return 2;
    return 1;
  }
  
  int _calculateCoins(int stars) {
    return _deliveriesCompleted * 2 + stars * 5;
  }

  /// Load a specific level
  void loadLevel(int levelId) {
    _setupLevel(levelId);
    
    // Update spawner difficulty with level-based progression
    game.spawner.setDifficulty(level: levelId);
    
    // Sync background scroll speed with spawner
    game.background.setScrollSpeed(game.spawner.currentSpeed);
  }
  
  /// Reset for restart
  void reset() {
    loadLevel(currentLevel.value);
  }
  
  int get targetScore => _targetScore;
}
