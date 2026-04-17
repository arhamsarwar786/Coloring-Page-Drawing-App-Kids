import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../model/color_model.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.palette,
    required this.selectedColorId,
    required this.onSelect,
  });

  final List<DrawingColorModel> palette;
  final String? selectedColorId;
  final ValueChanged<DrawingColorModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: palette.map((colorOption) {
          final isSelected = selectedColorId == colorOption.id;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelect(colorOption),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colorOption.color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF111111)
                        : Colors.white,
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorOption.color.withOpacity(0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
