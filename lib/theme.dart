import 'package:flutter/material.dart';

class NoxTheme {
  static const bg = Color(0xFF0A0A0A);
  static const bg2 = Color(0xFF111111);
  static const bg3 = Color(0xFF181818);
  static const card = Color(0xFF141414);
  static const border = Color(0x12FFFFFF);
  static const border2 = Color(0x1FFFFFFF);
  static const accent = Color(0xFFE8E8E8);
  static const accentDim = Color(0xFF666666);
  static const muted = Color(0xFF3A3A3A);
  static const textColor = Color(0xFFD4D4D4);
  static const text2 = Color(0xFF888888);

  static BoxDecoration cardDecoration({double radius = NoxTheme.radius}) {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
    );
  }

  static const radius = 16.0;
  static const radiusSm = 10.0;
}
