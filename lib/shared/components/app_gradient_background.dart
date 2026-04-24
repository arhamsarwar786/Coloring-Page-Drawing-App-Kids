import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.shell,
            Color(0xFFFFF3E7),
            Color(0xFFFFFCF8),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80,
            right: -40,
            child: _GlowOrb(color: AppColors.sky.withOpacity(0.24), size: 220),
          ),
          Positioned(
            left: -60,
            top: 120,
            child: _GlowOrb(color: AppColors.rose.withOpacity(0.16), size: 180),
          ),
          Positioned(
            bottom: -50,
            right: 40,
            child: _GlowOrb(color: AppColors.mint.withOpacity(0.2), size: 160),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}
