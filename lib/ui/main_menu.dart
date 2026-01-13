import 'package:flutter/material.dart';
import 'theme.dart';
import 'components/big_button.dart';
import '../game/food_dash_game.dart';

class MainMenu extends StatelessWidget {
  final FoodDashGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.creamCanvas.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppTheme.radiusStandard),
          border: Border.all(
            color: AppTheme.asphaltBlue,
            width: AppTheme.borderWidth,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo / Title
            Text(
              'FOOD DASH',
              style: AppTheme.headlineTextStyle.copyWith(
                color: AppTheme.dashOrange,
                fontSize: 48,
                shadows: [
                  const Shadow(
                    color: AppTheme.asphaltBlue,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            // Play Button
            BigButton(
              label: 'PLAY',
              onPressed: () {
                game.overlays.remove('MainMenu');
                game.overlays.add('LevelSelect');
              },
            ),
            const SizedBox(height: 16),
            
            // Shop Button
            BigButton(
              label: 'SHOP',
              backgroundColor: AppTheme.yolkYellow,
              borderColor: const Color(0xFFC49A00), // Darker yellow
              onPressed: () {
                 game.overlays.remove('MainMenu');
                 game.overlays.add('Shop');
              },
            ),
            const SizedBox(height: 16),
            
            // Settings Button
            BigButton(
              label: 'SETTINGS',
              backgroundColor: AppTheme.sidewalkGrey,
              borderColor: AppTheme.asphaltBlue,
              onPressed: () {
                game.overlays.remove('MainMenu');
                game.overlays.add('Settings');
              },
            ),
            const SizedBox(height: 16),
            
            // Dash Info Button (How to Play & Privacy Policy)
            BigButton(
              label: 'DASH',
              backgroundColor: AppTheme.lettuceGreen,
              borderColor: const Color(0xFF00994D), // Darker green
              onPressed: () {
                game.overlays.remove('MainMenu');
                game.overlays.add('DashInfo');
              },
            ),
          ],
        ),
      ),
    );
  }
}

