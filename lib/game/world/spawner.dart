import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../../utils/constants.dart';
import '../food_dash_game.dart';
import 'collectible.dart';
import 'obstacle.dart';

/// Handles spawning of collectibles and obstacles with progressive difficulty
class Spawner extends Component with HasGameReference<FoodDashGame> {
  final Random _random = Random();
  double _spawnTimer = 0;
  double _nextSpawnTime = 1.5;
  
  // Current difficulty parameters
  double _currentSpeed = GameConstants.baseScrollSpeed;
  double _obstacleChance = GameConstants.baseObstacleChance;
  double _minSpawnInterval = GameConstants.baseMinSpawnInterval;
  double _maxSpawnInterval = GameConstants.baseMaxSpawnInterval;
  int _currentLevel = 1;
  
  // Multi-lane spawn chance (increases with difficulty)
  double _multiLaneChance = 0.15;
  
  // Track recent spawns to ensure fairness and variety
  final List<int> _recentObstacleLanes = [];
  final List<int> _recentFoodLanes = [];
  int _consecutiveObstacleSpawns = 0;
  int _consecutiveFoodSpawns = 0;
  int _spawnsSinceLastObstacle = 0;

  @override
  void update(double dt) {
    super.update(dt);
    
    if (game.isPaused || game.isGameOver) return;
    
    _spawnTimer += dt;
    
    if (_spawnTimer >= _nextSpawnTime) {
      _spawnItem();
      _spawnTimer = 0;
      _calculateNextSpawnTime();
    }
  }
  
  void _calculateNextSpawnTime() {
    // Add slight variation to spawn timing
    _nextSpawnTime = _minSpawnInterval + 
        _random.nextDouble() * (_maxSpawnInterval - _minSpawnInterval);
    
    // Burst spawning starts from Level 3 for more engaging gameplay
    // Level 3-5: 8% chance, Level 6-10: 12% chance, Level 11+: 18% chance
    double burstChance = 0.0;
    if (_currentLevel >= 3 && _currentLevel <= 5) {
      burstChance = 0.08;
    } else if (_currentLevel >= 6 && _currentLevel <= 10) {
      burstChance = 0.12;
    } else if (_currentLevel >= 11) {
      burstChance = 0.18;
    }
    
    if (_random.nextDouble() < burstChance) {
      _nextSpawnTime *= 0.5; // Quick follow-up spawn for intensity
    }
  }
  
  void _spawnItem() {
    // Decide what to spawn based on balance rules
    final bool forceObstacle = _spawnsSinceLastObstacle >= 3; // Guarantee obstacle every 3-4 spawns
    final bool forceFoodVariety = _consecutiveFoodSpawns >= 2; // Force lane change after 2 food in same lane
    
    // Calculate if this spawn should be an obstacle
    bool spawnObstacle = forceObstacle || _shouldSpawnObstacle();
    
    // Don't spawn too many obstacles in a row
    if (_consecutiveObstacleSpawns >= 2) {
      spawnObstacle = false;
    }
    
    // Select lane(s) for spawning
    final lanes = _selectSpawnLanes(spawnObstacle, forceFoodVariety);
    
    if (spawnObstacle) {
      // Spawn obstacle(s)
      for (final lane in lanes) {
        _spawnObstacle(lane);
        _recentObstacleLanes.add(lane);
        if (_recentObstacleLanes.length > 4) {
          _recentObstacleLanes.removeAt(0);
        }
      }
      _consecutiveObstacleSpawns++;
      _consecutiveFoodSpawns = 0;
      _spawnsSinceLastObstacle = 0;
    } else {
      // Spawn food in one lane only (prevent clustering)
      final lane = lanes.first;
      _spawnCollectible(lane);
      _recentFoodLanes.add(lane);
      if (_recentFoodLanes.length > 3) {
        _recentFoodLanes.removeAt(0);
      }
      _consecutiveFoodSpawns++;
      _consecutiveObstacleSpawns = 0;
      _spawnsSinceLastObstacle++;
    }
  }
  
  bool _shouldSpawnObstacle() {
    // Base chance from difficulty settings
    double adjustedChance = _obstacleChance;
    
    // Increase chance if we haven't seen an obstacle recently
    if (_spawnsSinceLastObstacle >= 2) {
      adjustedChance += 0.15;
    }
    
    // Decrease chance if we've had consecutive obstacles
    if (_consecutiveObstacleSpawns >= 1) {
      adjustedChance *= 0.5;
    }
    
    return _random.nextDouble() < adjustedChance;
  }
  
  List<int> _selectSpawnLanes(bool forObstacle, bool forceLaneVariety) {
    final availableLanes = List.generate(GameConstants.laneCount, (i) => i);
    availableLanes.shuffle(_random);
    
    if (forObstacle) {
      // For obstacles: multi-lane spawning starts from Level 3
      int obstacleCount = 1;
      if (_currentLevel >= 3 && _random.nextDouble() < _multiLaneChance) {
        obstacleCount = 2; // Two obstacles for challenge
      }
      // At very high levels, occasionally spawn 3 obstacles (but always leave 1 safe lane)
      if (_currentLevel >= 20 && _random.nextDouble() < _multiLaneChance * 0.3) {
        obstacleCount = 2; // Max 2 to always leave safe path
      }
      
      // Prefer lanes that haven't had obstacles recently
      availableLanes.sort((a, b) {
        final aRecent = _recentObstacleLanes.where((l) => l == a).length;
        final bRecent = _recentObstacleLanes.where((l) => l == b).length;
        return aRecent - bRecent;
      });
      
      // Never block all lanes - always leave one safe path
      return availableLanes.take(obstacleCount.clamp(1, GameConstants.laneCount - 1)).toList();
    } else {
      // For food: single lane, avoid recent food lanes for variety
      if (forceLaneVariety || _random.nextDouble() < 0.7) {
        // Strongly prefer different lanes
        availableLanes.sort((a, b) {
          final aRecent = _recentFoodLanes.where((l) => l == a).length;
          final bRecent = _recentFoodLanes.where((l) => l == b).length;
          return aRecent - bRecent;
        });
      }
      return [availableLanes.first];
    }
  }
  
  void _spawnCollectible(int lane) {
    // Select random food type (with coffee/coin being rarer)
    FoodType type;
    final roll = _random.nextDouble();
    
    if (roll < 0.08) {
      // 8% chance for coin
      type = FoodType.coin;
    } else if (roll < 0.15) {
      // 7% chance for coffee (bonus)
      type = FoodType.coffee;
    } else {
      // Regular food items
      final regularFoods = [FoodType.burger, FoodType.pizza, FoodType.sushi];
      type = regularFoods[_random.nextInt(regularFoods.length)];
    }
    
    final collectible = Collectible(
      foodType: type,
      lane: lane,
      speed: _currentSpeed,
    );
    
    game.world.add(collectible);
  }
  
  void _spawnObstacle(int lane) {
    final obstacleTypes = ObstacleType.values;
    final type = obstacleTypes[_random.nextInt(obstacleTypes.length)];
    
    final obstacle = Obstacle(
      obstacleType: type,
      lane: lane,
      speed: _currentSpeed,
    );
    
    game.world.add(obstacle);
  }
  
  /// Update difficulty parameters based on level
  /// Key design: Levels 1-2 are tutorial/easy, Level 3+ introduces real challenge
  void setDifficulty({
    required int level,
    double? speed,
    double? obstacleChance,
  }) {
    _currentLevel = level;
    
    // Levels 1-2 are introductory (tutorial), Level 3+ introduces real challenge
    final bool isIntroLevel = level <= 2;
    
    // === SPEED: Major jump at Level 3, then aggressive scaling ===
    // Levels 1-2: 240-275 (gentle), Level 3: 355 (noticeable jump!)
    // Level 8: 530, Level 15: 775, Level 30: 950
    if (speed != null) {
      _currentSpeed = speed;
    } else {
      if (isIntroLevel) {
        // Gentle speed for first two levels
        _currentSpeed = GameConstants.baseScrollSpeed + (level - 1) * 35;
      } else {
        // Level 3+ gets the speed boost plus aggressive scaling
        _currentSpeed = GameConstants.baseScrollSpeed + 
            GameConstants.level3SpeedBoost + 
            (level - 1) * GameConstants.speedIncreasePerLevel;
      }
    }
    _currentSpeed = _currentSpeed.clamp(
      GameConstants.baseScrollSpeed,
      GameConstants.maxScrollSpeed,
    );
    
    // === OBSTACLE CHANCE: Major jump at Level 3 ===
    // Levels 1-2: 20-25% (learning phase), Level 3: 40% (challenge begins!)
    // Level 8: 50%, Level 15: 55%, Level 30: 65%
    if (obstacleChance != null) {
      _obstacleChance = obstacleChance;
    } else {
      if (isIntroLevel) {
        // Gentle obstacle chance for intro
        _obstacleChance = GameConstants.baseObstacleChance + (level - 1) * 0.05;
      } else {
        // Level 3+ starts at higher base and scales up
        _obstacleChance = GameConstants.level3ObstacleChance + 
            ((level - 3) / 27.0) * 0.25;
      }
    }
    _obstacleChance = _obstacleChance.clamp(
      GameConstants.baseObstacleChance, 
      GameConstants.maxObstacleChance,
    );
    
    // === SPAWN INTERVALS: Faster spawning from Level 3 ===
    // Levels 1-2: 1.0-1.8s, Level 3: 0.7-1.3s, Level 30: 0.35-0.6s
    if (isIntroLevel) {
      _minSpawnInterval = GameConstants.baseMinSpawnInterval;
      _maxSpawnInterval = GameConstants.baseMaxSpawnInterval;
    } else {
      // Level 3+ has faster spawning that scales
      final level3Progress = ((level - 3) / 27.0).clamp(0.0, 1.0);
      _minSpawnInterval = 0.7 - (level3Progress * 0.35);
      _maxSpawnInterval = 1.3 - (level3Progress * 0.7);
    }
    _minSpawnInterval = _minSpawnInterval.clamp(
      GameConstants.minSpawnIntervalFloor, 
      GameConstants.baseMinSpawnInterval,
    );
    _maxSpawnInterval = _maxSpawnInterval.clamp(
      GameConstants.maxSpawnIntervalFloor, 
      GameConstants.baseMaxSpawnInterval,
    );
    
    // === MULTI-LANE SPAWN: Earlier activation from Level 3 ===
    // Levels 1-2: 0%, Level 3-5: 15%, Level 8: 25%, Level 15+: 35-45%
    if (isIntroLevel) {
      _multiLaneChance = 0.0;
    } else if (level <= 5) {
      _multiLaneChance = 0.15;
    } else if (level <= 10) {
      _multiLaneChance = 0.20 + ((level - 5) / 5.0) * 0.10;
    } else {
      _multiLaneChance = 0.30 + ((level - 10) / 20.0) * 0.15;
    }
    _multiLaneChance = _multiLaneChance.clamp(0.0, 0.45);
    
    debugPrint('Spawner difficulty set: Level $level ${isIntroLevel ? "(Intro)" : "(Challenge Mode)"}');
    debugPrint('  Speed: ${_currentSpeed.toStringAsFixed(0)} px/s');
    debugPrint('  Obstacles: ${(_obstacleChance * 100).toStringAsFixed(0)}%');
    debugPrint('  Spawn interval: ${_minSpawnInterval.toStringAsFixed(2)}-${_maxSpawnInterval.toStringAsFixed(2)}s');
    debugPrint('  Multi-lane chance: ${(_multiLaneChance * 100).toStringAsFixed(0)}%');
  }
  
  /// Reset spawner state
  void reset() {
    _spawnTimer = 0;
    _nextSpawnTime = 1.5;
    _currentSpeed = GameConstants.baseScrollSpeed;
    _obstacleChance = GameConstants.baseObstacleChance;
    _minSpawnInterval = GameConstants.baseMinSpawnInterval;
    _maxSpawnInterval = GameConstants.baseMaxSpawnInterval;
    _currentLevel = 1;
    _multiLaneChance = 0.15;
    _recentObstacleLanes.clear();
    _recentFoodLanes.clear();
    _consecutiveObstacleSpawns = 0;
    _consecutiveFoodSpawns = 0;
    _spawnsSinceLastObstacle = 0;
  }
  
  double get currentSpeed => _currentSpeed;
}
