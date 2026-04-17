import 'package:flutter/material.dart';

class DoodleText extends StatelessWidget {
  const DoodleText(
    this.text, {
    super.key,
    this.fontSize = 28,
    this.fillColor = const Color(0xFF1FA8F4),
    this.outlineColor = Colors.white,
    this.shadowColor = const Color(0x33000000),
    this.fontWeight = FontWeight.w900,
    this.letterSpacing = 1.8,
    this.textAlign = TextAlign.center,
    this.strokeOffset = 2,
  });

  final String text;
  final double fontSize;
  final Color fillColor;
  final Color outlineColor;
  final Color shadowColor;
  final FontWeight fontWeight;
  final double letterSpacing;
  final TextAlign textAlign;
  final double strokeOffset;

  TextStyle get _textStyle => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: 1,
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Transform.translate(
          offset: const Offset(0, 4),
          child: Text(text,
              textAlign: textAlign,
              style: _textStyle.copyWith(color: shadowColor)),
        ),
        ...<Offset>[
          Offset(-strokeOffset, 0),
          Offset(strokeOffset, 0),
          Offset(0, -strokeOffset),
          Offset(0, strokeOffset),
        ].map(
          (offset) => Transform.translate(
            offset: offset,
            child: Text(text,
                textAlign: textAlign,
                style: _textStyle.copyWith(color: outlineColor)),
          ),
        ),
        Text(text,
            textAlign: textAlign,
            style: _textStyle.copyWith(color: fillColor)),
      ],
    );
  }
}
