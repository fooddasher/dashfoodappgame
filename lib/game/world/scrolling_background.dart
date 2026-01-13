import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import '../../utils/constants.dart';
import '../food_dash_game.dart';

/// Clean, performant scrolling background
///
/// Layout (centered road with grass on sides):
/// - Full viewport grass base layer
/// - Centered road with lane markings
/// - Parallax buildings on the grass sides
class ScrollingBackground extends PositionComponent
    with HasGameReference<FoodDashGame> {
  late double _scrollSpeed;

  // Road dimensions (calculated from constants)
  late double _roadX;
  late double _roadWidth;

  // Scrolling components
  late _ScrollingRoad _road;
  late _LaneMarkings _laneMarkings;
  late _ParallaxBuildings _buildings;
  late _SpeedLines _speedLines;

  @override
  Future<void> onLoad() async {
    _scrollSpeed = GameConstants.baseScrollSpeed;

    // Calculate layout - road centered with grass on sides
    _roadWidth = GameConstants.laneWidth * GameConstants.laneCount;
    _roadX = (GameConstants.viewportWidth - _roadWidth) / 2;

    // === LAYER 1: Full Background (Grass color) ===
    add(
      RectangleComponent(
        position: Vector2.zero(),
        size: Vector2(
          GameConstants.viewportWidth,
          GameConstants.viewportHeight,
        ),
        paint: Paint()..color = const Color(0xFF4CAF50), // Clean grass green
        priority: -10,
      ),
    );

    // === LAYER 2: Scrolling Road ===
    _road = _ScrollingRoad(roadX: _roadX, roadWidth: _roadWidth);
    add(_road);

    // === LAYER 3: Lane Markings ===
    _laneMarkings = _LaneMarkings(roadX: _roadX, roadWidth: _roadWidth);
    add(_laneMarkings);

    // === LAYER 4: Road Edge Lines (Yellow) ===
    _addRoadEdges();

    // === LAYER 5: Parallax Buildings on grass ===
    _buildings = _ParallaxBuildings(roadX: _roadX, roadWidth: _roadWidth);
    add(_buildings);

    // === LAYER 6: Speed Lines (motion indicator) ===
    _speedLines = _SpeedLines(roadX: _roadX, roadWidth: _roadWidth);
    add(_speedLines);
  }

  void _addRoadEdges() {
    final edgePaint = Paint()..color = const Color(0xFFFFEB3B); // Yellow
    const edgeWidth = 4.0;

    // Left edge of road
    add(
      RectangleComponent(
        position: Vector2(_roadX - edgeWidth / 2, 0),
        size: Vector2(edgeWidth, GameConstants.viewportHeight),
        paint: edgePaint,
        priority: -3,
      ),
    );

    // Right edge of road
    add(
      RectangleComponent(
        position: Vector2(_roadX + _roadWidth - edgeWidth / 2, 0),
        size: Vector2(edgeWidth, GameConstants.viewportHeight),
        paint: edgePaint,
        priority: -3,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.isPaused || game.isGameOver) return;

    final scrollAmount = _scrollSpeed * dt;

    // Scroll road texture
    _road.scroll(scrollAmount);

    // Scroll lane markings
    _laneMarkings.scroll(scrollAmount);

    // Scroll buildings at 70% speed for parallax depth
    _buildings.scroll(scrollAmount * 0.7);

    // Scroll speed lines at 120% speed for motion effect
    _speedLines.scroll(scrollAmount * 1.2);
  }

  void setScrollSpeed(double speed) {
    _scrollSpeed = speed.clamp(
      GameConstants.baseScrollSpeed,
      GameConstants.maxScrollSpeed,
    );
  }

  double get scrollSpeed => _scrollSpeed;
}

/// Scrolling road with asphalt texture effect
class _ScrollingRoad extends PositionComponent
    with HasGameReference<FoodDashGame> {
  final double roadX;
  final double roadWidth;

  double _scrollOffset = 0;
  static const double _textureHeight =
      100; // Height of repeating texture pattern

  late Paint _roadPaint;
  late Paint _texturePaint;

  _ScrollingRoad({required this.roadX, required this.roadWidth});

  @override
  Future<void> onLoad() async {
    position = Vector2(roadX, 0);
    size = Vector2(roadWidth, GameConstants.viewportHeight);
    priority = -5;

    // Base road color (dark asphalt)
    _roadPaint = Paint()..color = const Color(0xFF37474F);

    // Subtle texture lines
    _texturePaint = Paint()
      ..color = const Color(0xFF263238)
      ..strokeWidth = 1;
  }

  void scroll(double amount) {
    _scrollOffset = (_scrollOffset + amount) % _textureHeight;
  }

  @override
  void render(Canvas canvas) {
    // Draw base road
    canvas.drawRect(
      Rect.fromLTWH(0, 0, roadWidth, GameConstants.viewportHeight),
      _roadPaint,
    );

    // Draw subtle horizontal texture lines for scrolling effect
    double y = _scrollOffset - _textureHeight;
    while (y < GameConstants.viewportHeight) {
      canvas.drawLine(Offset(0, y), Offset(roadWidth, y), _texturePaint);
      y += _textureHeight;
    }
  }
}

/// Efficient lane markings using custom painting
class _LaneMarkings extends PositionComponent {
  final double roadX;
  final double roadWidth;
  double _scrollOffset = 0;

  static const double dashLength = 50;
  static const double gapLength = 30;
  static const double dashWidth = 8;
  static const double patternLength = dashLength + gapLength;

  late Paint _dashPaint;

  _LaneMarkings({required this.roadX, required this.roadWidth})
    : super(priority: -4);

  @override
  Future<void> onLoad() async {
    size = Vector2(roadWidth, GameConstants.viewportHeight);
    position = Vector2(roadX, 0);

    _dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
  }

  void scroll(double amount) {
    _scrollOffset = (_scrollOffset + amount) % patternLength;
  }

  @override
  void render(Canvas canvas) {
    // Draw dashed lines between lanes
    for (int lane = 1; lane < GameConstants.laneCount; lane++) {
      final x = (lane * GameConstants.laneWidth) - dashWidth / 2;

      double y = _scrollOffset - patternLength;
      while (y < GameConstants.viewportHeight) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, dashWidth, dashLength),
            const Radius.circular(3),
          ),
          _dashPaint,
        );
        y += patternLength;
      }
    }
  }
}

/// Parallax buildings on the grass sides
class _ParallaxBuildings extends Component with HasGameReference<FoodDashGame> {
  final double roadX;
  final double roadWidth;
  final List<_Building> _buildings = [];
  final Random _random = Random();

  double _spawnTimer = 0;
  double _nextSpawnTime = 0;

  static const List<String> _buildingAssets = [
    'small_cute_house.png',
    'burger_shop.png',
    'tall_blue_office.png',
  ];

  static const List<List<double>> _buildingSizes = [
    [70, 70], // small_cute_house
    [75, 75], // burger_shop
    [60, 100], // tall_blue_office
  ];

  _ParallaxBuildings({required this.roadX, required this.roadWidth});

  @override
  Future<void> onLoad() async {
    await _spawnInitialBuildings();
    _nextSpawnTime = 1.5 + _random.nextDouble();
  }

  Future<void> _spawnInitialBuildings() async {
    for (double y = 150; y < GameConstants.viewportHeight; y += 300) {
      await _spawnBuilding(isLeft: true, yPosition: y);
      await _spawnBuilding(isLeft: false, yPosition: y + 150);
    }
  }

  Future<void> _spawnBuilding({required bool isLeft, double? yPosition}) async {
    final assetIndex = _random.nextInt(_buildingAssets.length);
    final asset = _buildingAssets[assetIndex];
    final sizeData = _buildingSizes[assetIndex];

    final sprite = await game.loadSprite(asset);

    double x;
    if (isLeft) {
      // Position on left grass (0 to roadX)
      x = 5 + _random.nextDouble() * (roadX - sizeData[0] - 15);
      x = x.clamp(5, roadX - sizeData[0] - 5);
    } else {
      // Position on right grass (roadX + roadWidth to viewport edge)
      final rightGrassStart = roadX + roadWidth;
      final rightGrassWidth = GameConstants.viewportWidth - rightGrassStart;
      x =
          rightGrassStart +
          5 +
          _random.nextDouble() * (rightGrassWidth - sizeData[0] - 15);
      x = x.clamp(
        rightGrassStart + 5,
        GameConstants.viewportWidth - sizeData[0] - 5,
      );
    }

    final y = yPosition ?? -sizeData[1] - _random.nextDouble() * 30;

    final building = _Building(
      sprite: sprite,
      position: Vector2(x, y),
      size: Vector2(sizeData[0], sizeData[1]),
    );

    _buildings.add(building);
    add(building);
  }

  void scroll(double amount) {
    for (final building in _buildings.toList()) {
      building.position.y += amount;

      if (building.position.y > GameConstants.viewportHeight + 50) {
        building.removeFromParent();
        _buildings.remove(building);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.isPaused || game.isGameOver) return;

    _spawnTimer += dt;
    if (_spawnTimer >= _nextSpawnTime) {
      _spawnTimer = 0;
      _nextSpawnTime = 2.5 + _random.nextDouble() * 2.0;
      _spawnBuilding(isLeft: _random.nextBool());
    }
  }
}

class _Building extends SpriteComponent {
  _Building({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
  }) : super(sprite: sprite, position: position, size: size, priority: -2);
}

/// Speed lines to indicate motion/forward movement
class _SpeedLines extends PositionComponent {
  final double roadX;
  final double roadWidth;
  static const double lineLength = 40;
  static const double lineWidth = 3;
  static const double spacing = 180; // Vertical spacing between lines

  late Paint _linePaint;
  final List<_SpeedLine> _lines = [];
  final Random _random = Random();

  _SpeedLines({required this.roadX, required this.roadWidth})
    : super(priority: 1);

  @override
  Future<void> onLoad() async {
    size = Vector2(roadWidth, GameConstants.viewportHeight);
    position = Vector2(roadX, 0);

    _linePaint = Paint()
      ..color =
          const Color(0x40FFFFFF) // Semi-transparent white
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    // Create initial speed lines
    _initializeLines();
  }

  void _initializeLines() {
    for (
      double y = 0;
      y < GameConstants.viewportHeight + spacing;
      y += spacing
    ) {
      _addLine(y);
    }
  }

  void _addLine(double y) {
    // Random x position within the road (avoiding center to not obstruct view)
    final leftSide = _random.nextBool();
    double x;
    if (leftSide) {
      x = 20 + _random.nextDouble() * (roadWidth * 0.25);
    } else {
      x = roadWidth * 0.75 + _random.nextDouble() * (roadWidth * 0.2);
    }

    _lines.add(
      _SpeedLine(x: x, y: y, length: lineLength + _random.nextDouble() * 20),
    );
  }

  void scroll(double amount) {
    // Move all lines down and recycle ones that go off screen
    for (final line in _lines) {
      line.y += amount;
    }

    // Remove lines that are off screen and add new ones at top
    _lines.removeWhere((line) {
      if (line.y > GameConstants.viewportHeight + lineLength) {
        return true;
      }
      return false;
    });

    // Add new lines at top if needed
    while (_lines.isEmpty || _lines.first.y > spacing) {
      final newY = _lines.isEmpty ? -lineLength : _lines.first.y - spacing;
      _addLine(newY);
      _lines.sort((a, b) => a.y.compareTo(b.y));
    }
  }

  @override
  void render(Canvas canvas) {
    for (final line in _lines) {
      canvas.drawLine(
        Offset(line.x, line.y),
        Offset(line.x, line.y + line.length),
        _linePaint,
      );
    }
  }
}

class _SpeedLine {
  double x;
  double y;
  double length;

  _SpeedLine({required this.x, required this.y, required this.length});
}
