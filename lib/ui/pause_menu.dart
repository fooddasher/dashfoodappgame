import 'package:flutter/material.dart';
import 'theme.dart';
import '../game/food_dash_game.dart';
import 'components/big_button.dart';

class PauseMenu extends StatelessWidget {
  final FoodDashGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.creamCanvas.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppTheme.radiusStandard),
          border: Border.all(
            color: AppTheme.asphaltBlue,
            width: AppTheme.borderWidth,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: AppTheme.headlineTextStyle.copyWith(
                color: AppTheme.asphaltBlue,
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 32),
            BigButton(
              label: 'RESUME',
              onPressed: () {
                game.resumeGame();
              },
            ),
            const SizedBox(height: 16),
            BigButton(
              label: 'RESTART',
              backgroundColor: AppTheme.ketchupRed,
              borderColor: const Color(0xFFB01625),
              onPressed: () {
                game.restartGame();
              },
            ),
            const SizedBox(height: 16),
             TextButton(
              onPressed: () {
                 game.returnToMainMenu();
              },
              child: Text(
                'Exit to Menu',
                style: AppTheme.bodyTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

