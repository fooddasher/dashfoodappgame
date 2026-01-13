import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../ui/theme.dart';
import '../utils/constants.dart';
import 'actors/player.dart';
import 'game_manager.dart';
import 'audio_manager.dart';
import 'world/scrolling_background.dart';
import 'world/spawner.dart';
import 'world/collectible.dart';
import 'world/obstacle.dart';
import '../models/player_data.dart';

/// Main game class for Food Dash - Endless Runner Style
class FoodDashGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  FoodDashGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: GameConstants.viewportWidth,
          height: GameConstants.viewportHeight,
        ),
      );

  // Core components
  late final GameManager gameManager;
  late final AudioManager audioManager;
  late final PlayerComponent player;
  late final ScrollingBackground background;
  late final Spawner spawner;

  // Player data (save system)
  final PlayerData playerData = PlayerData();

  // Game state
  int score = 0;
  bool isGameOver = false;
  bool isPaused = false;

  @override
  Color backgroundColor() => AppTheme.asphaltBlue;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Start paused (Main Menu shown)
    isPaused = true;
    debugMode = false;

    // Ensure camera is properly centered on the game world
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    // Initialize Audio
    audioManager = AudioManager();
    await add(audioManager);

    // Initialize Player Data
    await playerData.init();

    // Initialize Game Manager
    gameManager = GameManager();
    await world.add(gameManager);

    // Create scrolling background
    background = ScrollingBackground();
    await world.add(background);

    // Create spawner
    spawner = Spawner();
    await world.add(spawner);

    // Create player
    player = PlayerComponent();
    await world.add(player);

    // Apply saved color customization
    player.setTintColor(Color(playerData.equippedColor));

    // Listen for player data changes
    playerData.addListener(_onPlayerDataChanged);

    debugPrint('Food Dash Game loaded!');

    // Start background music
    audioManager.playBgm();
  }

  void _onPlayerDataChanged() {
    if (player.isMounted) {
      player.setTintColor(Color(playerData.equippedColor));
    }
  }

  @override
  void onRemove() {
    playerData.removeListener(_onPlayerDataChanged);
    super.onRemove();
  }

  // Drag state tracking
  bool _isDragging = false;

  /// Handle drag start - begin player movement
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (isPaused || isGameOver) return;
    _isDragging = true;
    player.startDrag();
  }

  /// Handle drag update - move player horizontally
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isPaused || isGameOver || !_isDragging) return;

    // Convert screen position to game world position
    final worldPos = camera.globalToLocal(
      event.localStartPosition + event.localDelta,
    );
    player.dragTo(worldPos.x);
  }

  /// Handle drag end - stop dragging
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    player.endDrag();
  }

  /// Handle drag cancel
  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isDragging = false;
    player.endDrag();
  }

  @override
  void update(double dt) {
    if (isPaused || isGameOver) return;
    super.update(dt);
  }

  /// Load and start a level
  Future<void> loadLevel(int levelId) async {
    // Clear existing items
    _clearGameItems();

    // Reset spawner
    spawner.reset();

    // Setup level via game manager
    gameManager.loadLevel(levelId);

    // Reset player position
    player.reset();

    // Show tutorial for first-time players
    if (!playerData.tutorialShown) {
      overlays.add('Tutorial');
      playerData.markTutorialShown();
    }

    // Resume game
    resumeGame();
  }

  void _clearGameItems() {
    // Remove all collectibles and obstacles
    world.children.whereType<Collectible>().forEach(
      (c) => c.removeFromParent(),
    );
    world.children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
  }

  /// Pause the game
  void pauseGame() {
    isPaused = true;
    overlays.add('PauseMenu');
    audioManager.pauseBgm();
  }

  /// Resume the game
  void resumeGame() {
    isPaused = false;
    overlays.remove('PauseMenu');
    audioManager.resumeBgm();
  }

  /// Restart current level
  void restartGame() {
    score = 0;
    isGameOver = false;
    isPaused = false;

    // Clear menus
    overlays.remove('PauseMenu');
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    overlays.remove('MainMenu');
    overlays.remove('LevelSelect');

    // Ensure HUD is visible
    overlays.add('HUD');

    // Reload current level
    loadLevel(gameManager.currentLevel.value);

    audioManager.resumeBgm();
  }

  /// End the game (failure)
  void gameOver() {
    isGameOver = true;
    overlays.add('GameOver');
    audioManager.stopBgm();
    audioManager.playSfx('game_over.mp3');
  }

  /// Level complete (success)
  void levelComplete(int stars, int coins) {
    isPaused = true;
    overlays.add('LevelComplete');
    audioManager.playSfx('deliery_success.mp3');
  }

  /// Add points to the score (legacy support for HUD)
  void addScore(int points) {
    score += points;
  }

  /// Return to main menu (from game over, level complete, or pause)
  void returnToMainMenu() {
    // Reset game state
    isGameOver = false;
    isPaused = true;
    score = 0;

    // Clear all overlays
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    overlays.remove('PauseMenu');
    overlays.remove('HUD');
    overlays.remove('Tutorial');

    // Show main menu
    overlays.add('MainMenu');

    // Clear game items
    _clearGameItems();

    // Restart background music for menu
    audioManager.playBgm();
  }
}
