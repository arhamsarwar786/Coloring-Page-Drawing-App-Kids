import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/interaction_feedback.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
  });

  final String label;
  final FutureOr<void> Function()? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed == null
          ? null
          : () => handleTapAction(context, onPressed),
      icon: icon ?? const SizedBox.shrink(),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }
}
