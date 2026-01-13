import 'package:flutter/material.dart';
import 'theme.dart';
import '../game/food_dash_game.dart';
import 'components/big_button.dart';

class GameOverScreen extends StatelessWidget {
  final FoodDashGame game;

  const GameOverScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final score = game.gameManager.score.value;
    final targetScore = game.gameManager.targetScore;
    final level = game.gameManager.currentLevel.value;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
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
            // Sad emoji
            Text(
              '😞',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            
            Text(
              'TIME\'S UP!',
              style: AppTheme.headlineTextStyle.copyWith(
                color: AppTheme.ketchupRed,
                fontSize: 36,
                shadows: [
                  const Shadow(
                    color: AppTheme.asphaltBlue,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Level $level',
              style: AppTheme.bodyTextStyle.copyWith(
                fontSize: 16,
                color: AppTheme.asphaltBlue,
              ),
            ),
            const SizedBox(height: 24),
            
            // Score vs Target
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.ketchupRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.ketchupRed.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Score: ',
                        style: AppTheme.bodyTextStyle.copyWith(fontSize: 18),
                      ),
                      Text(
                        '$score',
                        style: AppTheme.headlineTextStyle.copyWith(
                          color: AppTheme.ketchupRed,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Needed: $targetScore',
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontSize: 14,
                      color: AppTheme.sidewalkGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            BigButton(
              label: 'TRY AGAIN',
              onPressed: () {
                game.restartGame();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                game.returnToMainMenu();
              },
              child: Text(
                'Back to Menu',
                style: AppTheme.bodyTextStyle.copyWith(
                  color: AppTheme.asphaltBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
