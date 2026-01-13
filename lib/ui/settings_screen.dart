import 'package:flutter/material.dart';
import '../game/food_dash_game.dart';
import 'theme.dart';
import 'components/big_button.dart';

class SettingsScreen extends StatefulWidget {
  final FoodDashGame game;

  const SettingsScreen({super.key, required this.game});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
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
              'SETTINGS',
              style: AppTheme.headlineTextStyle.copyWith(
                fontSize: 32,
                color: AppTheme.asphaltBlue,
              ),
            ),
            const SizedBox(height: 32),

            // Music Toggle
            _buildSettingRow('Music', widget.game.audioManager.musicEnabled, (
              val,
            ) {
              widget.game.audioManager.setMusicEnabled(val);
              setState(() {});
            }),
            const SizedBox(height: 16),

            // SFX Toggle
            _buildSettingRow('Sound FX', widget.game.audioManager.sfxEnabled, (
              val,
            ) {
              widget.game.audioManager.setSfxEnabled(val);
              setState(() {});
            }),
            const SizedBox(height: 32),

            BigButton(
              label: 'BACK',
              backgroundColor: AppTheme.sidewalkGrey,
              borderColor: AppTheme.asphaltBlue,
              onPressed: () {
                widget.game.overlays.remove('Settings');
                widget.game.overlays.add('MainMenu');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyTextStyle.copyWith(fontSize: 24)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppTheme.dashOrange.withValues(alpha: 0.5),
          activeThumbColor: AppTheme.dashOrange,
          inactiveTrackColor: AppTheme.sidewalkGrey,
          inactiveThumbColor: AppTheme.asphaltBlue,
        ),
      ],
    );
  }
}
