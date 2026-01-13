import '../utils/constants.dart';

/// Simplified level data for endless runner style gameplay
class LevelData {
  final int id;
  final String zone; // "suburbia", "city", "night_market"
  final double timeLimit;
  final int targetScore;
  final double scrollSpeed;
  final double obstacleChance;

  const LevelData({
    required this.id,
    required this.zone,
    required this.timeLimit,
    required this.targetScore,
    required this.scrollSpeed,
    required this.obstacleChance,
  });
}

class LevelDefinitions {
  /// Get level configuration by ID (1-30)
  /// Key design: Levels 1-2 are introductory, Level 3+ introduces real challenge
  static LevelData getLevel(int id) {
    // Determine zone based on level
    String zone;
    if (id <= 10) {
      zone = 'suburbia';
    } else if (id <= 20) {
      zone = 'city';
    } else {
      zone = 'night_market';
    }
    
    final bool isIntroLevel = id <= 2;
    
    // Time limits: Adjusted to balance faster gameplay from Level 3+
    // Intro levels get less time (simpler), Level 3+ gets more to account for obstacles
    double timeLimit;
    if (isIntroLevel) {
      timeLimit = 40.0; // Short intro levels
    } else if (id <= GameConstants.easyLevelCap) {
      timeLimit = 50.0; // Levels 3-5: More time for increased challenge
    } else if (id <= GameConstants.mediumLevelCap) {
      timeLimit = 55.0; // Medium levels: Balanced with speed increase
    } else if (id <= GameConstants.hardLevelCap) {
      timeLimit = 60.0; // Hard levels: More obstacles need more time
    } else {
      timeLimit = 55.0; // Expert: Tight but fair
    }
    
    // Target scores - adjusted to be achievable despite obstacles
    // Faster speed = more items pass by = more opportunities, but obstacles slow you down
    int targetScore;
    if (isIntroLevel) {
      targetScore = 100 + (id - 1) * 30; // Easy intro: 100, 130
    } else if (id <= GameConstants.easyLevelCap) {
      targetScore = 160 + (id - 3) * 25; // Levels 3-5: 160, 185, 210
    } else if (id <= GameConstants.mediumLevelCap) {
      final levelInTier = id - GameConstants.easyLevelCap;
      targetScore = 230 + levelInTier * 22; // Levels 6-15
    } else if (id <= GameConstants.hardLevelCap) {
      final levelInTier = id - GameConstants.mediumLevelCap;
      targetScore = 450 + levelInTier * 20; // Levels 16-25
    } else {
      final levelInTier = id - GameConstants.hardLevelCap;
      targetScore = 650 + levelInTier * 25; // Levels 26-30
    }
    
    // Scroll speed with Level 3 jump
    double scrollSpeed;
    if (isIntroLevel) {
      scrollSpeed = GameConstants.baseScrollSpeed + (id - 1) * 35;
    } else {
      scrollSpeed = GameConstants.baseScrollSpeed + 
          GameConstants.level3SpeedBoost + 
          (id - 1) * GameConstants.speedIncreasePerLevel;
    }
    
    // Obstacle chance with Level 3 jump
    double obstacleChance;
    if (isIntroLevel) {
      obstacleChance = GameConstants.baseObstacleChance + (id - 1) * 0.05;
    } else {
      obstacleChance = GameConstants.level3ObstacleChance + 
          ((id - 3) / 27.0) * 0.25;
    }
    
    return LevelData(
      id: id,
      zone: zone,
      timeLimit: timeLimit,
      targetScore: targetScore,
      scrollSpeed: scrollSpeed.clamp(GameConstants.baseScrollSpeed, GameConstants.maxScrollSpeed),
      obstacleChance: obstacleChance.clamp(GameConstants.baseObstacleChance, GameConstants.maxObstacleChance),
    );
  }
  
  /// Get zone display name
  static String getZoneName(String zone) {
    switch (zone) {
      case 'suburbia':
        return 'Suburbia';
      case 'city':
        return 'Downtown';
      case 'night_market':
        return 'Night Market';
      default:
        return 'Unknown';
    }
  }
}
