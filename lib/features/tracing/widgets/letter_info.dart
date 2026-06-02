import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/tracing/constants/app_images.dart';

class LetterInfo {
  final String letter;
  final String word;
  final String animal;
  final IconData iconData;
  final Color color;
  final String? imagePath;

  const LetterInfo({
    required this.letter,
    required this.word,
    required this.animal,
    required this.iconData,
    required this.color,
    this.imagePath,
  });

  static Map<String, LetterInfo> getLetterData() {
    return {
      'A': LetterInfo(
        letter: 'A',
        word: 'Alligator',
        animal: '🐊',
        iconData: Icons.pets,
        color: const Color(0xFF6A1B9A),
        imagePath: AppImages.aligatorImage,
      ),
      'B': LetterInfo(
        letter: 'B',
        word: 'Bear',
        animal: '🐻',
        iconData: Icons.pets,
        color: const Color(0xFF6A1B9A),
        imagePath: AppImages.bearImage,
      ),
      'C': LetterInfo(
        letter: 'C',
        word: 'Cat',
        animal: '🐱',
        iconData: Icons.pets,
        color: const Color(0xFF6A1B9A),
        imagePath: AppImages.catImage,
      ),
      'D': LetterInfo(
        letter: 'D',
        word: 'Dog',
        animal: '🐶',
        iconData: Icons.pets,
        color: const Color(0xFF6A1B9A),
        imagePath: AppImages.dogImage,
      ),
      'E': LetterInfo(
        letter: 'E',
        word: 'Elephant',
        animal: '🐘',
        iconData: Icons.pets,
        color: const Color(0xFF6A1B9A),
        imagePath: AppImages.elephantImage,
      ),
      // 'F': LetterInfo(
      //   letter: 'F',
      //   word: 'Fox',
      //   animal: '🦊',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'G': LetterInfo(
      //   letter: 'G',
      //   word: 'Giraffe',
      //   animal: '🦒',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'H': LetterInfo(
      //   letter: 'H',
      //   word: 'Horse',
      //   animal: '🐴',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'I': LetterInfo(
      //   letter: 'I',
      //   word: 'Iguana',
      //   animal: '🦎',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'J': LetterInfo(
      //   letter: 'J',
      //   word: 'Jellyfish',
      //   animal: '🪼',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'K': LetterInfo(
      //   letter: 'K',
      //   word: 'Koala',
      //   animal: '🐨',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      'L': LetterInfo(
        letter: 'L',
        word: 'Lion',
        animal: '🦁',
        iconData: Icons.pets,
        color: const Color(0xFF6A1B9A),
        imagePath: AppImages.lionImage,
      ),
      // 'M': LetterInfo(
      //   letter: 'M',
      //   word: 'Monkey',
      //   animal: '🐵',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'N': LetterInfo(
      //   letter: 'N',
      //   word: 'Narwhal',
      //   animal: '🐋',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'O': LetterInfo(
      //   letter: 'O',
      //   word: 'Owl',
      //   animal: '🦉',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'P': LetterInfo(
      //   letter: 'P',
      //   word: 'Penguin',
      //   animal: '🐧',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'Q': LetterInfo(
      //   letter: 'Q',
      //   word: 'Quail',
      //   animal: '🐦',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'R': LetterInfo(
      //   letter: 'R',
      //   word: 'Rabbit',
      //   animal: '🐰',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'S': LetterInfo(
      //   letter: 'S',
      //   word: 'Snake',
      //   animal: '🐍',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'T': LetterInfo(
      //   letter: 'T',
      //   word: 'Tiger',
      //   animal: '🐯',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'U': LetterInfo(
      //   letter: 'U',
      //   word: 'Urchin',
      //   animal: '🦔',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'V': LetterInfo(
      //   letter: 'V',
      //   word: 'Vulture',
      //   animal: '🦅',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'W': LetterInfo(
      //   letter: 'W',
      //   word: 'Whale',
      //   animal: '🐳',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'X': LetterInfo(
      //   letter: 'X',
      //   word: 'Xray Fish',
      //   animal: '🐠',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'Y': LetterInfo(
      //   letter: 'Y',
      //   word: 'Yak',
      //   animal: '🐂',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
      // 'Z': LetterInfo(
      //   letter: 'Z',
      //   word: 'Zebra',
      //   animal: '🦓',
      //   iconData: Icons.pets,
      //   color: const Color(0xFF6A1B9A),
      // ),
    };
  }

  static LetterInfo getInfo(String letter) {
    final data = getLetterData();
    return data[letter.toUpperCase()] ??
        LetterInfo(
          letter: letter,
          word: 'Unknown',
          animal: '?',
          iconData: Icons.help_outline,
          color: const Color(0xFF6A1B9A),
        );
  }
}
