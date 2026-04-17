import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.onReset,
  });

  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _CircleToolButton(
          icon: Icons.undo_rounded,
          label: AppStrings.undo,
          enabled: canUndo,
          onTap: onUndo,
        ),
        _CircleToolButton(
          icon: Icons.redo_rounded,
          label: AppStrings.redo,
          enabled: canRedo,
          onTap: onRedo,
        ),
        _CircleToolButton(
          icon: Icons.close_rounded,
          label: AppStrings.reset,
          enabled: true,
          onTap: onReset,
        ),
      ],
    );
  }
}

class _CircleToolButton extends StatelessWidget {
  const _CircleToolButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Column(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color(0xFF222222), width: 2),
              ),
              child: Icon(icon, color: const Color(0xFF111111)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
