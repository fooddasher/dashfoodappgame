import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../food_dash_game.dart';

/// Player component for the endless runner style game
/// The rider can be dragged freely across lanes
class PlayerComponent extends SpriteComponent
    with HasGameReference<FoodDashGame>, CollisionCallbacks {
  // Movement state
  double _targetX = 0;
  bool _isDragging = false;

  // Boundaries for movement (within road)
  late double _minX;
  late double _maxX;

  // Slowdown state (penalty for hitting obstacles)
  bool _isSlowedDown = false;
  double _slowdownTimer = 0;
  double _slowdownMultiplier = 1.0;
  final double _normalMoveSpeed = 1500.0;

  PlayerComponent();

  @override
  Future<void> onLoad() async {
    // Set explicit priority to render above all background elements
    priority = 10;

    // Load the upward-facing rider sprite (since we're moving "forward")
    try {
      sprite = await game.loadSprite('rider_facing_up.png');
    } catch (e) {
      debugPrint('Failed to load player sprite: $e');
    }

    // Set size
    size = Vector2.all(GameConstants.playerSize);
    anchor = Anchor.center;

    // Calculate movement boundaries (stay within road)
    final roadLeft = GameConstants.roadLeftMargin;
    final roadRight =
        roadLeft + (GameConstants.laneWidth * GameConstants.laneCount);
    _minX = roadLeft + size.x / 2;
    _maxX = roadRight - size.x / 2;

    // Initial position: center of road, near bottom
    _targetX = GameConstants.getLaneCenterX(1); // Center lane
    position = Vector2(
      _targetX,
      GameConstants.viewportHeight - GameConstants.playerBottomOffset,
    );

    // Debug fallback: if sprite fails to load, show a colored rectangle
    if (sprite == null) {
      debugPrint('Player sprite is null - adding fallback visual');
      add(
        RectangleComponent(
          size: size,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFFFF6B35), // Dash Orange
        ),
      );
    }

    // Add hitbox for collision detection
    add(
      CircleHitbox(
        radius: GameConstants.playerSize * 0.35,
        position: Vector2.all(GameConstants.playerSize * 0.15),
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    debugPrint(
      'Player mounted at: $position with size: $size, priority: $priority',
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle slowdown timer
    if (_isSlowedDown) {
      _slowdownTimer -= dt;
      if (_slowdownTimer <= 0) {
        _isSlowedDown = false;
        _slowdownMultiplier = 1.0;
        // Clear the red tint when slowdown ends
        paint.colorFilter = null;
      }
    }

    // Smooth movement to target position when not being dragged
    if (!_isDragging) {
      final diff = _targetX - position.x;
      if (diff.abs() > 1) {
        // Apply slowdown multiplier to movement speed
        final moveSpeed = _normalMoveSpeed * _slowdownMultiplier;
        final moveAmount = moveSpeed * dt;

        if (diff.abs() <= moveAmount) {
          position.x = _targetX;
        } else {
          position.x += diff.sign * moveAmount;
        }
      }
    }
  }

  /// Called when drag starts
  void startDrag() {
    _isDragging = true;
  }

  /// Move player to the dragged X position
  void dragTo(double x) {
    if (_isDragging) {
      // Clamp position within road boundaries
      final targetX = x.clamp(_minX, _maxX);

      // Apply slowdown effect - player moves more sluggishly when slowed
      if (_isSlowedDown) {
        // Interpolate towards target with reduced responsiveness
        final diff = targetX - position.x;
        _targetX = position.x + (diff * _slowdownMultiplier);
        _targetX = _targetX.clamp(_minX, _maxX);
        position.x = _targetX;
      } else {
        _targetX = targetX;
        position.x = _targetX;
      }
    }
  }

  /// Called when drag ends
  void endDrag() {
    _isDragging = false;
    // Optionally snap to nearest lane center for visual consistency
    // (Comment out if you want completely free positioning)
    // _snapToNearestLane();
  }

  /// Snap to the nearest lane center (optional - can be enabled in endDrag if desired)
  // ignore: unused_element
  void _snapToNearestLane() {
    int nearestLane = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < GameConstants.laneCount; i++) {
      final laneX = GameConstants.getLaneCenterX(i);
      final distance = (position.x - laneX).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearestLane = i;
      }
    }

    _targetX = GameConstants.getLaneCenterX(nearestLane);
  }

  /// Apply tint color for customization
  void setTintColor(Color color) {
    if (color.toARGB32() != 0xFFFFFFFF) {
      paint.colorFilter = ColorFilter.mode(color, BlendMode.srcATop);
    } else {
      paint.colorFilter = null;
    }
  }

  /// Reset player to center of road
  void reset() {
    _targetX = GameConstants.getLaneCenterX(1);
    position.x = _targetX;
    _isDragging = false;
    _isSlowedDown = false;
    _slowdownTimer = 0;
    _slowdownMultiplier = 1.0;
    paint.colorFilter = null;
  }

  /// Apply slowdown effect as penalty for hitting obstacles
  void applySlowdown(double duration, double multiplier) {
    _isSlowedDown = true;
    _slowdownTimer = duration;
    _slowdownMultiplier = multiplier;
  }

  /// Check if player is currently slowed down
  bool get isSlowedDown => _isSlowedDown;

  /// Get current lane (approximate, based on position)
  int get currentLane {
    for (int i = 0; i < GameConstants.laneCount; i++) {
      final laneX = GameConstants.getLaneCenterX(i);
      if ((position.x - laneX).abs() < GameConstants.laneWidth / 2) {
        return i;
      }
    }
    return 1; // Default to center
  }
}
