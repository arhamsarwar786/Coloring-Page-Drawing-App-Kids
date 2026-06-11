import 'package:flutter/material.dart';

/// Brand palette derived from the PlayCraft Kids logo.
/// Primary: Royal Blue | Secondary: Hot Pink | Accent: Sunshine Yellow
abstract final class AppColors {
  // ── Logo primary colours ──────────────────────────────────────────────────
  /// Sunshine Yellow  — "Play" wordmark
  static const Color yellow = Color(0xFFFFC700);

  /// Royal Blue       — "Craft" wordmark & paintbrush character
  static const Color blue = Color(0xFF1565C0);

  /// Hot Pink         — "Kids" wordmark & paint splat
  static const Color pink = Color(0xFFFF3D80);

  /// Vivid Purple     — paint splat & stars
  static const Color purple = Color(0xFF8B2FC9);

  /// Lime Green       — paint splat dots
  static const Color green = Color(0xFF3EC63E);

  /// Bright Orange    — paint splat
  static const Color orange = Color(0xFFFF8C00);

  // ── Structural / semantic colours ────────────────────────────────────────
  /// Deep Navy — text outlines, primary text (logo outline colour)
  static const Color ink = Color(0xFF1A237E);

  /// Soft White — surface / scaffold background
  static const Color shell = Color(0xFFFFFBF5);

  /// Light Blue-White — card background
  static const Color card = Color(0xFFF0F4FF);

  /// Muted warm grey — secondary text
  static const Color warmGrey = Color(0xFF6D6A7A);

  // ── Legacy aliases kept for backward-compat ───────────────────────────────
  static const Color rose = pink;
  static const Color coral = orange;
  static const Color peach = Color(0xFFFFF0D9);
  static const Color sky = Color(0xFF64B5F6);
  static const Color mint = Color(0xFF80DEEA);
  static const Color success = green;
  static const Color warning = orange;
}
