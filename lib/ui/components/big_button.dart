import 'package:flutter/material.dart';
import '../theme.dart';

class BigButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final double width;

  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.borderColor,
    this.width = 200,
  });

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppTheme.dashOrange;
    final borderColor = widget.borderColor ?? AppTheme.dashOrangeBorder;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: widget.width,
        height: 60,
        margin: EdgeInsets.only(
          top: _isPressed ? 4 : 0,
          bottom: _isPressed ? 0 : 4,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          border: Border.all(
            color: borderColor,
            width: AppTheme.buttonBorderWidth,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: AppTheme.buttonTextStyle,
        ),
      ),
    );
  }
}

