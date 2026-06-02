import 'package:flutter/material.dart';

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
      color: fromHex(json['hex'] as String),
    );
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
