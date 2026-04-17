import 'dart:ui';
import 'package:flutter/material.dart';

enum RegionType { circle, oval, polygon }

class RegionModel {
  final String id;
  final String label;
  final RegionType type;
  final double? cx;
  final double? cy;
  final double? radius;
  final double? rx;
  final double? ry;
  final List<Offset> points;
  
  RegionModel({
    required this.id,
    required this.label,
    required this.type,
    this.cx,
    this.cy,
    this.radius,
    this.rx,
    this.ry,
    this.points = const [],
  });
  
  factory RegionModel.fromJson(Map<String, dynamic> json) {
    RegionType type;
    switch (json['type']) {
      case 'circle':
        type = RegionType.circle;
        break;
      case 'oval':
        type = RegionType.oval;
        break;
      case 'polygon':
        type = RegionType.polygon;
        break;
      default:
        type = RegionType.oval;
    }
    
    List<Offset> points = [];
    if (json['points'] != null) {
      points = (json['points'] as List).map((p) {
        return Offset(p[0].toDouble(), p[1].toDouble());
      }).toList();
    }
    
    return RegionModel(
      id: json['id'],
      label: json['label'],
      type: type,
      cx: json['cx']?.toDouble(),
      cy: json['cy']?.toDouble(),
      radius: json['radius']?.toDouble(),
      rx: json['rx']?.toDouble(),
      ry: json['ry']?.toDouble(),
      points: points,
    );
  }
  
  Path toPath(Size size) {
    final path = Path();
    
    switch (type) {
      case RegionType.circle:
        path.addOval(Rect.fromCircle(
          center: Offset((cx ?? 0.5) * size.width, (cy ?? 0.5) * size.height),
          radius: (radius ?? 0.2) * size.shortestSide,
        ));
        break;
        
      case RegionType.oval:
        path.addOval(Rect.fromCenter(
          center: Offset((cx ?? 0.5) * size.width, (cy ?? 0.5) * size.height),
          width: (rx ?? 0.25) * 2 * size.width,
          height: (ry ?? 0.25) * 2 * size.height,
        ));
        break;
        
      case RegionType.polygon:
        if (points.isNotEmpty) {
          path.moveTo(points.first.dx * size.width, points.first.dy * size.height);
          for (var i = 1; i < points.length; i++) {
            path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
          }
          path.close();
        }
        break;
    }
    
    return path;
  }
  
  bool containsPoint(Offset point, Size size) {
    return toPath(size).contains(point);
  }
}
