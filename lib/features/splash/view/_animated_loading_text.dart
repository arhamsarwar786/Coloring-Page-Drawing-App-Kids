import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedLoadingText extends StatefulWidget {
  const AnimatedLoadingText({super.key});

  @override
  State<AnimatedLoadingText> createState() =>
      _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _shimmer = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        const gradient = LinearGradient(
          colors: [
            Color(0xFFFFADAD), // Light Red
            Color(0xFFFFD6A5), // Light Orange
            Color(0xFFFDFFB6), // Light Yellow
            Color(0xFFCAFFBF), // Light Green
            Color(0xFF9BFBC0), // Light Teal
            Color(0xFFA0C4FF), // Light Blue
            Color(0xFFBDB2FF), // Light Indigo
            Color(0xFFFFC6FF), // Light Pink
          ],
        );
        return ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            'LOADING...',
            style: GoogleFonts.fredoka(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4.0,
            ),
          ),
        );
      },
    );
  }
}
