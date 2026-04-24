import 'package:flutter/material.dart';

class StickerIconButton extends StatelessWidget {
  const StickerIconButton({
    super.key,
    required this.icon,
    this.assetName,
    required this.onPressed,
    this.size = 40,
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
      child: assetName != null
          ? Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1.5))
              ], shape: BoxShape.circle),
              width: size,
              height: size,
              child: Image.asset(
                assetName!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(icon, color: iconColor, size: size * 0.5),
              ),
            )
          : Icon(icon, color: iconColor, size: size * 0.5),
    );
  }
}
