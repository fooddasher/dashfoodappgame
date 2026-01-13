import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/food_dash_game.dart';
import 'ui/theme.dart';
import 'ui/main_menu.dart';
import 'ui/level_select.dart';
import 'ui/shop_screen.dart';
import 'ui/hud_overlay.dart';
import 'ui/pause_menu.dart';
import 'ui/game_over_screen.dart';
import 'ui/level_complete_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/tutorial_overlay.dart';
import 'ui/dash_info_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for the game
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const FoodDashApp());
}

class FoodDashApp extends StatelessWidget {
  const FoodDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Dash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<FoodDashGame>.controlled(
        gameFactory: FoodDashGame.new,
        overlayBuilderMap: {
          'MainMenu': (_, game) => MainMenu(game: game),
          'LevelSelect': (_, game) => LevelSelect(game: game),
          'Shop': (_, game) => ShopScreen(game: game),
          'HUD': (_, game) => HUDOverlay(game: game),
          'PauseMenu': (_, game) => PauseMenu(game: game),
          'GameOver': (_, game) => GameOverScreen(game: game),
          'LevelComplete': (_, game) => LevelCompleteScreen(game: game),
          'Settings': (_, game) => SettingsScreen(game: game),
          'Tutorial': (_, game) => TutorialOverlay(game: game),
          'DashInfo': (_, game) => DashInfoScreen(game: game),
        },
        // Initial overlay is MainMenu (we'll set this via the game or just let the game add it on load)
        // Ideally we start with MainMenu.
        initialActiveOverlays: const ['MainMenu'], 
      ),
    );
  }
}
