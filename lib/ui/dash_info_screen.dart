import 'package:flutter/material.dart';
import 'theme.dart';
import 'components/big_button.dart';
import '../game/food_dash_game.dart';

class DashInfoScreen extends StatelessWidget {
  final FoodDashGame game;

  const DashInfoScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 700),
        margin: const EdgeInsets.all(16),
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.dashOrange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusStandard - 3),
                  topRight: Radius.circular(AppTheme.radiusStandard - 3),
                ),
              ),
              child: Text(
                'DASH',
                textAlign: TextAlign.center,
                style: AppTheme.headlineTextStyle.copyWith(
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
            ),
            
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // How to Dash Section
                    _buildSectionHeader('🎮 How to Dash'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      children: [
                        _buildBulletPoint('Drag left or right to move your delivery rider between lanes.'),
                        _buildBulletPoint('Collect food items (🍔 burgers, 🍕 pizza, 🍣 sushi) to earn points.'),
                        _buildBulletPoint('Grab coffee ☕ for bonus points and coins 🪙 for extra rewards!'),
                        _buildBulletPoint('Avoid obstacles like traffic cones, trash cans, oil puddles, and stray dogs.'),
                        _buildBulletPoint('Hitting obstacles costs you points, time, and slows you down temporarily.'),
                        _buildBulletPoint('Reach the target score before time runs out to complete each level.'),
                        _buildBulletPoint('As levels progress, the game gets faster and obstacles appear more frequently!'),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Privacy Policy Section
                    _buildSectionHeader('🔒 Privacy Policy'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      children: [
                        Text(
                          'Your privacy matters to us. Here\'s what you need to know:',
                          style: AppTheme.bodyTextStyle.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint('We do not collect any personal information.'),
                        _buildBulletPoint('Game progress is stored locally on your device only.'),
                        _buildBulletPoint('No data is shared with third parties.'),
                        _buildBulletPoint('No account or login is required to play.'),
                        _buildBulletPoint('The game does not require internet connection to play.'),
                        const SizedBox(height: 8),
                        Text(
                          'Play with peace of mind - your data stays with you!',
                          style: AppTheme.bodyTextStyle.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            color: AppTheme.sidewalkGrey,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Back Button
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 8),
              child: BigButton(
                label: 'BACK',
                backgroundColor: AppTheme.sidewalkGrey,
                borderColor: AppTheme.asphaltBlue,
                onPressed: () {
                  game.overlays.remove('DashInfo');
                  game.overlays.add('MainMenu');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.headlineTextStyle.copyWith(
        color: AppTheme.dashOrange,
        fontSize: 24,
        shadows: [
          const Shadow(
            color: AppTheme.asphaltBlue,
            offset: Offset(1, 1),
            blurRadius: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusInner),
        border: Border.all(
          color: AppTheme.sidewalkGrey.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTheme.bodyTextStyle.copyWith(
              color: AppTheme.lettuceGreen,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyTextStyle.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
