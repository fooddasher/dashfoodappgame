import 'package:flutter/material.dart';
import 'theme.dart';
import '../game/food_dash_game.dart';
import '../models/level_data.dart';

class LevelSelect extends StatelessWidget {
  final FoodDashGame game;

  const LevelSelect({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.asphaltBlue,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 32),
                    onPressed: () {
                      game.overlays.remove('LevelSelect');
                      game.overlays.add('MainMenu');
                    },
                  ),
                  Expanded(
                    child: Text(
                      'SELECT LEVEL',
                      textAlign: TextAlign.center,
                      style: AppTheme.headlineTextStyle.copyWith(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Zone tabs (simplified visual indicator)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildZoneTab('Suburbia', '1-10', AppTheme.lettuceGreen),
                  _buildZoneTab('Downtown', '11-20', AppTheme.sidewalkGrey),
                  _buildZoneTab('Night', '21-30', const Color(0xFF3F51B5)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid
            Expanded(
              child: AnimatedBuilder(
                animation: game.playerData,
                builder: (context, child) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final levelData = LevelDefinitions.getLevel(level);
                      bool isLocked = level > game.playerData.unlockedLevels;
                      int score = game.playerData.getHighScore(level);
                      
                      // Calculate stars based on score vs target
                      int stars = 0;
                      if (score > 0) {
                        final ratio = score / levelData.targetScore;
                        if (ratio >= 1.5) {
                          stars = 3;
                        } else if (ratio >= 1.2) {
                          stars = 2;
                        } else {
                          stars = 1;
                        }
                      }

                      return _buildLevelButton(level, levelData.zone, isLocked, stars);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildZoneTab(String name, String range, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: AppTheme.bodyTextStyle.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            range,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(int level, String zone, bool isLocked, int stars) {
    // Zone-based colors
    Color accentColor;
    switch (zone) {
      case 'suburbia':
        accentColor = AppTheme.lettuceGreen;
        break;
      case 'city':
        accentColor = AppTheme.dashOrange;
        break;
      case 'night_market':
        accentColor = const Color(0xFF7C4DFF);
        break;
      default:
        accentColor = AppTheme.dashOrange;
    }
    
    return GestureDetector(
      onTap: isLocked ? null : () {
        game.overlays.remove('LevelSelect');
        game.overlays.add('HUD');
        game.loadLevel(level);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? AppTheme.sidewalkGrey : AppTheme.creamCanvas,
          borderRadius: BorderRadius.circular(AppTheme.radiusInner),
          border: Border.all(
            color: isLocked ? AppTheme.asphaltBlue : accentColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$level',
              style: AppTheme.headlineTextStyle.copyWith(
                color: isLocked ? AppTheme.asphaltBlue : accentColor,
                fontSize: 32,
              ),
            ),
            if (!isLocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Icon(
                  i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 16,
                  color: i < stars ? AppTheme.yolkYellow : AppTheme.sidewalkGrey,
                )),
              )
            else 
              const Icon(Icons.lock, color: AppTheme.asphaltBlue, size: 20),
          ],
        ),
      ),
    );
  }
}
