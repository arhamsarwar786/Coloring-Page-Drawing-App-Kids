import 'package:flutter/material.dart';

import '../../../core/utils/color_parser.dart';

class DrawingColorModel {
  const DrawingColorModel({
    required this.id,
    required this.label,
    required this.color,
  });

  final String id;
  final String label;
  final Color color;

  factory DrawingColorModel.fromJson(Map<String, dynamic> json) {
    return DrawingColorModel(
      id: json['id'] as String,
      label: json['label'] as String,
      color: ColorParser.fromHex(json['hex'] as String),
    );
  }
}
