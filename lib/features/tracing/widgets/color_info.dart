import 'package:flutter/material.dart';

class ColorInfo {
  final String letter;
  final String word;
  final Color color;

  const ColorInfo({
    required this.letter,
    required this.word,
    required this.color,
  });

  static List<ColorInfo> getColorData() {
    return [
      const ColorInfo(letter: 'A', word: 'Aqua', color: Color(0xFF00FFFF)),
      const ColorInfo(letter: 'B', word: 'Blue', color: Colors.blue),
      const ColorInfo(letter: 'C', word: 'Coral', color: Color(0xFFFF7F50)),
      const ColorInfo(letter: 'D', word: 'Denim', color: Color(0xFF1560BD)),
      const ColorInfo(letter: 'E', word: 'Emerald', color: Color(0xFF50C878)),
      const ColorInfo(letter: 'F', word: 'Fuchsia', color: Color(0xFFFF00FF)),
      const ColorInfo(letter: 'G', word: 'Green', color: Colors.green),
      const ColorInfo(letter: 'H', word: 'Hot Pink', color: Color(0xFFFF69B4)),
      const ColorInfo(letter: 'I', word: 'Indigo', color: Colors.indigo),
      const ColorInfo(letter: 'J', word: 'Jade', color: Color(0xFF00A86B)),
      const ColorInfo(letter: 'K', word: 'Khaki', color: Color(0xFFC3B091)),
      const ColorInfo(letter: 'L', word: 'Lavender', color: Color(0xFFE6E6FA)),
      const ColorInfo(letter: 'M', word: 'Mint', color: Color(0xFF3EB489)),
      const ColorInfo(letter: 'N', word: 'Navy', color: Color(0xFF000080)),
      const ColorInfo(letter: 'O', word: 'Orange', color: Colors.orange),
      const ColorInfo(letter: 'P', word: 'Purple', color: Colors.purple),
      const ColorInfo(letter: 'Q', word: 'Quartz', color: Color(0xFF51414F)),
      const ColorInfo(letter: 'R', word: 'Red', color: Colors.red),
      const ColorInfo(letter: 'S', word: 'Silver', color: Color(0xFFC0C0C0)),
      const ColorInfo(letter: 'T', word: 'Teal', color: Colors.teal),
      const ColorInfo(letter: 'U', word: 'Ultramarine', color: Color(0xFF3F00FF)),
      const ColorInfo(letter: 'V', word: 'Violet', color: Color(0xFF8F00FF)),
      const ColorInfo(letter: 'W', word: 'White', color: Colors.white),
      const ColorInfo(letter: 'X', word: 'Xanadu', color: Color(0xFF738678)),
      const ColorInfo(letter: 'Y', word: 'Yellow', color: Colors.yellow),
      const ColorInfo(letter: 'Z', word: 'Zaffre', color: Color(0xFF0014A8)),
    ];
  }

  static ColorInfo getInfo(String letter) {
    final data = getColorData();
    return data.firstWhere(
      (c) => c.letter.toUpperCase() == letter.toUpperCase(),
      orElse: () => const ColorInfo(
        letter: 'A',
        word: 'Aqua',
        color: Color(0xFF00FFFF),
      ),
    );
  }
}
