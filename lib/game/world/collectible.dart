import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../../utils/constants.dart';
import '../food_dash_game.dart';
import '../actors/player.dart';
import '../actors/particles.dart';

/// Types of collectible food items
enum FoodType {
  burger('cheesburger.png', GameConstants.foodPoints),
  pizza('pizza.png', GameConstants.foodPoints),
  sushi('sushi_roll.png', GameConstants.foodPoints),
  coffee('coffee_cup.png', GameConstants.bonusFoodPoints), // Bonus item
  coin('coin.png', GameConstants.bonusFoodPoints);
  
  final String assetName;
  final int points;
  
  const FoodType(this.assetName, this.points);
}

/// Food collectible that moves down the screen
class Collectible extends SpriteComponent 
    with HasGameReference<FoodDashGame>, CollisionCallbacks {
  
  final FoodType foodType;
  final int lane;
  double _speed = GameConstants.baseScrollSpeed;
  bool _collected = false;

  Collectible({
    required this.foodType,
    required this.lane,
    double? speed,
  }) : super(
    size: Vector2.all(GameConstants.collectibleSize),
    anchor: Anchor.center,
  ) {
    if (speed != null) _speed = speed;
  }

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite(foodType.assetName);
    
    // Position at top of screen in the specified lane
    position = Vector2(
      GameConstants.getLaneCenterX(lane),
      -GameConstants.collectibleSize,
    );
    
    // Add hitbox
    add(CircleHitbox(
      radius: GameConstants.collectibleSize * 0.4,
      position: Vector2.all(GameConstants.collectibleSize * 0.1),
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
    
    if (other is PlayerComponent && !_collected) {
      _collected = true;
      
      // Add score
      game.gameManager.addScore(foodType.points);
      
      // Play pickup sound
      game.audioManager.playSfx('pickup_chime.mp3');
      
      // Visual effect
      game.world.add(PopParticle(position: position.clone()));
      
      // Remove collectible
      removeFromParent();
    }
  }
  
  void setSpeed(double speed) {
    _speed = speed;
  }
}

