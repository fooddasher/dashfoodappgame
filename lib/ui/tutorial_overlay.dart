import 'package:flutter/material.dart';
import 'theme.dart';
import '../game/food_dash_game.dart';

/// First-time player tutorial overlay
/// Shows tap instructions and auto-dismisses after 3 seconds or first tap
class TutorialOverlay extends StatefulWidget {
  final FoodDashGame game;

  const TutorialOverlay({super.key, required this.game});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_dismissed) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.game.overlays.remove('Tutorial');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.translucent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'HOW TO PLAY',
                  style: AppTheme.headlineTextStyle.copyWith(
                    color: AppTheme.yolkYellow,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 48),

                // Drag instruction
                _buildDragInstruction(),

                const SizedBox(height: 48),

                // Goal
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lettuceGreen.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppTheme.radiusStandard),
                    border: Border.all(
                      color: const Color(0xFF2E7D32),
                      width: AppTheme.borderWidth,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fastfood,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Collect food!',
                            style: AppTheme.bodyTextStyle.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            color: AppTheme.dashOrange,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Avoid obstacles!',
                            style: AppTheme.bodyTextStyle.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Tap to continue
                Text(
                  'Tap anywhere to start',
                  style: AppTheme.bodyTextStyle.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragInstruction() {
    return Column(
      children: [
        // Drag visualization
        Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.asphaltBlue.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.dashOrange,
              width: 3,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arrows showing horizontal movement
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 32,
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.dashOrange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE55A00),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.pan_tool,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 32,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'DRAG to move',
          textAlign: TextAlign.center,
          style: AppTheme.headlineTextStyle.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Slide your finger left or right\nto dodge obstacles',
          textAlign: TextAlign.center,
          style: AppTheme.bodyTextStyle.copyWith(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
