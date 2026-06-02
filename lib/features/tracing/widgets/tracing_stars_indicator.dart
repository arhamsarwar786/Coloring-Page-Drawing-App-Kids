// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/tracing/constants/app_colors.dart';

class TracingStarsIndicator extends StatelessWidget {
  final int stars;

  const TracingStarsIndicator({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i < stars;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          transform: Matrix4.identity()..scale(active ? 1.0 : 0.85),
          child: Icon(
            active ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 34,
            color: active
                ? AppColors.starActiveYellow
                : AppColors.starInactivePurple,
          ),
        );
      }),
    );
  }
}
