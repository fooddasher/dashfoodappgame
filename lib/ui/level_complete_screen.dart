import 'package:flutter/material.dart';
import 'theme.dart';
import 'components/big_button.dart';
import '../game/food_dash_game.dart';

class LevelCompleteScreen extends StatelessWidget {
  final FoodDashGame game;

  const LevelCompleteScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final currentLevel = game.gameManager.currentLevel.value;
    final score = game.gameManager.score.value;
    final targetScore = game.gameManager.targetScore;
    
    // Calculate stars
    final ratio = score / targetScore;
    int stars;
    if (ratio >= 1.5) {
      stars = 3;
    } else if (ratio >= 1.2) {
      stars = 2;
    } else {
      stars = 1;
    }
    
    // Calculate coins earned
    final coins = (score ~/ 10) * 2 + stars * 5;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
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
            // Title
            Text(
              'LEVEL COMPLETE!',
              style: AppTheme.headlineTextStyle.copyWith(
                fontSize: 28,
                color: AppTheme.lettuceGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Level $currentLevel',
              style: AppTheme.bodyTextStyle.copyWith(
                fontSize: 18,
                color: AppTheme.asphaltBlue,
              ),
            ),
            const SizedBox(height: 24),
            
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppTheme.yolkYellow,
                    size: 48,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            
            // Score
            _buildStatRow('Score', '$score', Icons.check_circle_rounded, AppTheme.lettuceGreen),
            const SizedBox(height: 8),
            _buildStatRow('Target', '$targetScore', Icons.flag_rounded, AppTheme.dashOrange),
            const SizedBox(height: 8),
            _buildStatRow('Coins', '+$coins', Icons.monetization_on_rounded, AppTheme.yolkYellow),
            
            const SizedBox(height: 32),
            
            // Buttons
            if (currentLevel < 30)
              BigButton(
                label: 'NEXT LEVEL',
                onPressed: () {
                  game.overlays.remove('LevelComplete');
                  game.loadLevel(currentLevel + 1);
                },
              ),
            const SizedBox(height: 12),
            BigButton(
              label: 'MENU',
              backgroundColor: AppTheme.sidewalkGrey,
              borderColor: AppTheme.asphaltBlue,
              onPressed: () {
                game.returnToMainMenu();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.bodyTextStyle.copyWith(fontSize: 18),
        ),
        Text(
          value,
          style: AppTheme.headlineTextStyle.copyWith(
            fontSize: 20,
            color: color,
          ),
        ),
      ],
    );
  }
}
