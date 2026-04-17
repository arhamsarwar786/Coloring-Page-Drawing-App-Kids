import 'package:flutter/material.dart';

class StickerIconButton extends StatelessWidget {
  const StickerIconButton({
    super.key,
    required this.icon,
    this.assetName,
    required this.onPressed,
    this.size = 54,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFF111111),
    this.iconColor = const Color(0xFF111111),
  });

  final IconData icon;
  final String? assetName;
  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: assetName != null
            ? Padding(
                padding: EdgeInsets.all(size * 0.14),
                child: Image.asset(
                  assetName!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(icon, color: iconColor, size: size * 0.5),
                ),
              )
            : Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}
