import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ActivityItem {
  final String id;
  final String label;
  final String display;
  final Color color;
  final String? imagePath;

  const ActivityItem({
    required this.id,
    required this.label,
    required this.display,
    required this.color,
    this.imagePath,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    log('${json}');
    Color color = Colors.red;
    if (json.containsKey("color")) {
      // TODO: parse actual color if needed
    }
    return ActivityItem(
      id: json['id'] ?? '',
      label: json['label'] ?? json['lable'] ?? '',
      display: json['display'] ?? '',
      color: color,
      imagePath: json['imagePath'],
    );
  }

  String get letter {
    switch (label.toLowerCase()) {
      case 'zero':
        return '0';
      case 'one':
        return '1';
      case 'two':
        return '2';
      case 'three':
        return '3';
      case 'four':
        return '4';
      case 'five':
        return '5';
      case 'six':
        return '6';
      case 'seven':
        return '7';
      case 'eight':
        return '8';
      case 'nine':
        return '9';
      default:
        return label.isNotEmpty ? label[0].toUpperCase() : 'A';
    }
  }
}
