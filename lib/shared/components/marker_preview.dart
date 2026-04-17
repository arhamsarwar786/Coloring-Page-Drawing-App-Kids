import 'dart:math' as math;

import 'package:flutter/material.dart';

class MarkerPreview extends StatelessWidget {
  const MarkerPreview({
    super.key,
    required this.barrelColor,
    required this.capColor,
    this.bandColor = const Color(0xFFEAEAEA),
    this.nibColor = const Color(0xFF2D2D2D),
    this.showFace = false,
    this.size = 120,
    this.angle = 0,
  });

  final Color barrelColor;
  final Color capColor;
  final Color bandColor;
  final Color nibColor;
  final bool showFace;
  final double size;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final width = size * 0.34;
    return Transform.rotate(
      angle: angle * math.pi / 180,
      child: SizedBox(
        width: width,
        height: size,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: size * 0.18,
              left: width * 0.14,
              right: width * 0.14,
              bottom: size * 0.16,
              child: Container(
                decoration: BoxDecoration(
                  color: barrelColor,
                  borderRadius: BorderRadius.circular(width * 0.45),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: size * 0.06,
              left: width * 0.07,
              right: width * 0.07,
              height: size * 0.26,
              child: Container(
                decoration: BoxDecoration(
                  color: capColor,
                  borderRadius: BorderRadius.circular(width * 0.5),
                ),
              ),
            ),
            Positioned(
              top: size * 0.24,
              left: width * 0.08,
              right: width * 0.08,
              height: size * 0.07,
              child: Container(
                decoration: BoxDecoration(
                  color: bandColor,
                  borderRadius: BorderRadius.circular(width * 0.2),
                ),
              ),
            ),
            if (showFace)
              Positioned(
                top: size * 0.46,
                left: width * 0.18,
                right: width * 0.18,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List<Widget>.generate(
                        2,
                        (_) => Container(
                          width: width * 0.1,
                          height: width * 0.1,
                          decoration: const BoxDecoration(
                            color: Color(0xFF333333),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size * 0.03),
                    Container(
                      width: width * 0.24,
                      height: size * 0.05,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF333333), width: 2),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              bottom: size * 0.06,
              left: width * 0.22,
              right: width * 0.22,
              height: size * 0.16,
              child: ClipPath(
                clipper: _NibClipper(),
                child: Container(color: nibColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NibClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
