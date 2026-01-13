import 'package:flutter/material.dart';
import 'theme.dart';
import '../game/food_dash_game.dart';

class ShopScreen extends StatefulWidget {
  final FoodDashGame game;

  const ShopScreen({super.key, required this.game});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // Define available colors
  final List<Map<String, dynamic>> availableColors = [
    {'name': 'Dash Orange', 'color': 0xFFFF9000},
    {'name': 'Eco Green', 'color': 0xFF4CAF50},
    {'name': 'Speed Red', 'color': 0xFFE53935},
    {'name': 'Sky Blue', 'color': 0xFF2196F3},
  ];

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
                      widget.game.overlays.remove('Shop');
                      widget.game.overlays.add('MainMenu');
                    },
                  ),
                  Expanded(
                    child: Text(
                      'SHOP',
                      textAlign: TextAlign.center,
                      style: AppTheme.headlineTextStyle.copyWith(fontSize: 32),
                    ),
                  ),
                   const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: availableColors.length,
                itemBuilder: (context, index) {
                  final item = availableColors[index];
                  final colorInt = item['color'] as int;
                  final isEquipped = widget.game.playerData.equippedColor == colorInt;

                  return _buildShopItem(
                    name: item['name'] as String,
                    color: Color(colorInt),
                    isEquipped: isEquipped,
                    onTap: () async {
                      await widget.game.playerData.setEquippedColor(colorInt);
                      setState(() {});
                      // Update player tint if game is running/loaded? 
                      // For now, PlayerComponent reads from playerData or we need to push update.
                      // Phase 2 plan: "Allow the sprite color to be tinted via paint.colorFilter"
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

  Widget _buildShopItem({
    required String name,
    required Color color,
    required bool isEquipped,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.creamCanvas,
          borderRadius: BorderRadius.circular(AppTheme.radiusInner),
          border: Border.all(
            color: isEquipped ? AppTheme.dashOrange : Colors.transparent,
            width: isEquipped ? 4 : 0,
          ),
          boxShadow: [
             BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.delivery_dining, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.asphaltBlue),
            ),
            const SizedBox(height: 8),
            Text(
              isEquipped ? "EQUIPPED" : "SELECT",
              style: AppTheme.bodyTextStyle.copyWith(
                color: isEquipped ? AppTheme.dashOrange : AppTheme.sidewalkGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
