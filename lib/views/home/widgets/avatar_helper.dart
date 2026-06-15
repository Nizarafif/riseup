import 'package:flutter/material.dart';

class AvatarData {
  final String emoji;
  final List<Color> gradientColors;
  const AvatarData(this.emoji, this.gradientColors);
}

const List<AvatarData> presetAvatars = [
  AvatarData('😊', [Color(0xFF80EE98), Color(0xFF46CDCF)]), // Happy face / teal
  AvatarData('🌸', [
    Color(0xFFFEC8D8),
    Color(0xFFD291BC),
  ]), // Cherry blossom / pink/purple
  AvatarData('⭐', [Color(0xFFFFE57F), Color(0xFFFFD54F)]), // Star / yellow
  AvatarData('☁️', [Color(0xFFBAE6FD), Color(0xFF38BDF8)]), // Cloud / sky blue
  AvatarData('🍃', [Color(0xFFA7F3D0), Color(0xFF059669)]), // Leaf / emerald
  AvatarData('🐱', [Color(0xFFFFD1A9), Color(0xFFFF9E79)]), // Cat / orange
  AvatarData('🌟', [
    Color(0xFFFFF176),
    Color(0xFFF57F17),
  ]), // Glowing Star / deep gold
  AvatarData('🌈', [
    Color(0xFFFFD1D1),
    Color(0xFFD1E8E2),
  ]), // Rainbow / pastel multi
  AvatarData('🧸', [
    Color(0xFFE2B4BD),
    Color(0xFF9B5DE5),
  ]), // Teddy Bear / soft purple
  AvatarData('🦊', [Color(0xFFFFE3E3), Color(0xFFFF7043)]), // Fox / coral red
  AvatarData('☕', [
    Color(0xFFD7CCC8),
    Color(0xFF8D6E63),
  ]), // Coffee cup / warm brown
  AvatarData('🎨', [Color(0xFFE1BEE7), Color(0xFF8E24AA)]), // Palette / violet
];
