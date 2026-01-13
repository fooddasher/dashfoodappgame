class GameConstants {
  // Screen Configuration (720x1280 viewport)
  static const double viewportWidth = 720.0;
  static const double viewportHeight = 1280.0;
  
  // Lane System - Road spans ~92% of viewport for immersive endless runner feel
  static const int laneCount = 3;
  static const double laneWidth = 220.0; // Wider lanes for better visibility
  static const double roadLeftMargin = 30.0; // Minimal grass margins (720 - 3*220) / 2
  
  // Player Configuration
  static const double playerSize = 96.0; // Increased for better visibility (1.5x collectibles)
  static const double playerBottomOffset = 150.0; // Distance from bottom
  static const double laneSwitchDuration = 0.15; // Seconds for smooth transition
  
  // Scrolling Speed - Progressive difficulty (noticeable increase each level)
  // Levels 1-2: Gentle introduction, Level 3+: Aggressive speed ramp
  static const double baseScrollSpeed = 240.0; // Slower start for Level 1-2
  static const double level3SpeedBoost = 80.0; // Extra speed jump at level 3
  static const double maxScrollSpeed = 950.0; // Higher max for late game challenge
  static const double speedIncreasePerLevel = 35.0; // More aggressive per-level increase
  
  // Spawning - Base values (modified by difficulty)
  // Levels 1-2: Relaxed spawning to learn, Level 3+: More active spawning
  static const double baseMinSpawnInterval = 1.0; // Slower spawning for intro levels
  static const double baseMaxSpawnInterval = 1.8;
  static const double minSpawnIntervalFloor = 0.35; // Faster at hardest levels
  static const double maxSpawnIntervalFloor = 0.6;
  static const double baseObstacleChance = 0.20; // Lower for intro (levels 1-2)
  static const double level3ObstacleChance = 0.40; // Jump in obstacles at level 3
  static const double maxObstacleChance = 0.65; // Cap at 65% for intense late game
  
  // Item Sizes
  static const double collectibleSize = 64.0;
  static const double obstacleSize = 64.0;
  
  // Scoring
  static const int foodPoints = 10;
  static const int bonusFoodPoints = 25;
  static const int obstaclePenalty = 15; // Points lost on obstacle hit
  
  // Obstacle Penalties
  static const double obstacleTimePenalty = 2.5; // Seconds lost on obstacle hit
  static const double obstacleSlowdownDuration = 1.5; // How long slowdown lasts
  static const double obstacleSlowdownMultiplier = 0.4; // Movement speed multiplier during slowdown
  
  // Game Settings
  static const double baseGameTime = 60.0; // seconds per level
  
  // Difficulty Tiers (for smoother progression)
  static const int easyLevelCap = 5;      // Levels 1-5: Easy
  static const int mediumLevelCap = 15;   // Levels 6-15: Medium
  static const int hardLevelCap = 25;     // Levels 16-25: Hard
  // Levels 26-30: Expert
  
  // Helper to get lane center X position
  static double getLaneCenterX(int lane) {
    // lane 0 = left, lane 1 = center, lane 2 = right
    return roadLeftMargin + (lane * laneWidth) + (laneWidth / 2);
  }
}
