import 'package:flutter/material.dart';

class SkinModel {
  const SkinModel({
    required this.id,
    this.image,
    required this.barrelColor,
    required this.capColor,
    this.bandColor = const Color(0xFFEAEAEA),
    this.nibColor = const Color(0xFF222222),
    this.requiresAd = false,
    this.face = false,
  });

  final String id;
  final String? image;
  final Color barrelColor;
  final Color capColor;
  final Color bandColor;
  final Color nibColor;
  final bool requiresAd;
  final bool face;
}
