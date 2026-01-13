import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../food_dash_game.dart';
import '../actors/player.dart';

/// Types of obstacles to avoid
enum ObstacleType {
  trafficCone('traffic_cone.png'),
  trashCan('trash_can.png'),
  oilPuddle('oil_puddle.png'),
  dog('stray_dog.png');
  
  final String assetName;
  
  const ObstacleType(this.assetName);
}

/// Obstacle that moves down the screen - player must avoid
class Obstacle extends SpriteComponent 
    with HasGameReference<FoodDashGame>, CollisionCallbacks {
  
  final ObstacleType obstacleType;
  final int lane;
  double _speed = GameConstants.baseScrollSpeed;
  bool _hit = false;

  Obstacle({
    required this.obstacleType,
    required this.lane,
    double? speed,
  }) : super(
    size: Vector2.all(GameConstants.obstacleSize),
    anchor: Anchor.center,
  ) {
    if (speed != null) _speed = speed;
  }

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite(obstacleType.assetName);
    
    // Position at top of screen in the specified lane
    position = Vector2(
      GameConstants.getLaneCenterX(lane),
      -GameConstants.obstacleSize,
    );
    
    // Add hitbox
    add(RectangleHitbox(
      size: Vector2.all(GameConstants.obstacleSize * 0.7),
      position: Vector2.all(GameConstants.obstacleSize * 0.15),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (game.isPaused || game.isGameOver) return;
    
    // Move down
    position.y += _speed * dt;
    
    // Remove if off screen
    if (position.y > GameConstants.viewportHeight + 100) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is PlayerComponent && !_hit) {
      _hit = true;
      
      // === REAL PENALTIES FOR HITTING OBSTACLES ===
      
      // 1. Deduct score (but don't go below 0)
      game.gameManager.deductScore(GameConstants.obstaclePenalty);
      
      // 2. Deduct time - lose precious seconds!
      game.gameManager.deductTime(GameConstants.obstacleTimePenalty);
      
      // 3. Apply slowdown effect to player movement
      game.player.applySlowdown(
        GameConstants.obstacleSlowdownDuration,
        GameConstants.obstacleSlowdownMultiplier,
      );
      
      // Play hit sound
      game.audioManager.playSfx('carton_thud.mp3');
      
      // Flash effect on player
      _flashPlayer();
      
      // Remove obstacle
      removeFromParent();
    }
  }
  
  void _flashPlayer() {
    // Visual feedback - flash player red during slowdown duration
    final player = game.player;
    
    player.paint.colorFilter = const ColorFilter.mode(Colors.red, BlendMode.srcATop);
    
    // Keep flashing for the duration of slowdown to indicate penalty
    Future.delayed(Duration(milliseconds: (GameConstants.obstacleSlowdownDuration * 1000).toInt()), () {
      if (player.isMounted && !player.isSlowedDown) {
        player.paint.colorFilter = null;
      }
    });
  }
  
  void setSpeed(double speed) {
    _speed = speed;
  }
}

