import 'package:flutter/material.dart';
import 'theme.dart';
import '../game/food_dash_game.dart';

class HUDOverlay extends StatelessWidget {
  final FoodDashGame game;

  const HUDOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Top row with score, level, and timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score Panel
                ValueListenableBuilder<int>(
                  valueListenable: game.gameManager.score,
                  builder: (context, score, child) {
                    return _buildPanel(
                      icon: Icons.star_rounded,
                      iconColor: AppTheme.yolkYellow,
                      text: '$score',
                      subText: '/ ${game.gameManager.targetScore}',
                    );
                  },
                ),
                
                // Level indicator
                ValueListenableBuilder<int>(
                  valueListenable: game.gameManager.currentLevel,
                  builder: (context, level, child) {
                    return _buildLevelBadge(level);
                  },
                ),
                
                // Timer Panel
                ValueListenableBuilder<double>(
                  valueListenable: game.gameManager.timeRemaining,
                  builder: (context, time, child) {
                    final isWarning = time <= 10;
                    return _buildPanel(
                      icon: Icons.timer_rounded,
                      iconColor: isWarning ? Colors.red : AppTheme.dashOrange,
                      text: '${time.ceil()}s',
                      highlight: isWarning,
                    );
                  },
                ),
              ],
            ),
            
            // Pause button
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => game.pauseGame(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.creamCanvas,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.asphaltBlue, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pause_rounded,
                    color: AppTheme.asphaltBlue,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel({
    required IconData icon,
    required Color iconColor,
    required String text,
    String? subText,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: highlight 
            ? Colors.red.withValues(alpha: 0.9)
            : AppTheme.creamCanvas.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        border: Border.all(
          color: highlight ? Colors.red.shade900 : AppTheme.asphaltBlue,
          width: 3,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: highlight ? Colors.white : iconColor, size: 24),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTheme.headlineTextStyle.copyWith(
              color: highlight ? Colors.white : AppTheme.asphaltBlue,
              fontSize: 20,
            ),
          ),
          if (subText != null)
            Text(
              subText,
              style: AppTheme.bodyTextStyle.copyWith(
                color: highlight ? Colors.white70 : AppTheme.sidewalkGrey,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLevelBadge(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.dashOrange,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        'LV $level',
        style: AppTheme.headlineTextStyle.copyWith(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
