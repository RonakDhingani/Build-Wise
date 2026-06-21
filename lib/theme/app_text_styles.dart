import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle get _base => const TextStyle(
        fontFamily: 'Inter',
        color: LightThemeColors.textPrimary,
        letterSpacing: -0.1,
      );

  // Display — hero numbers
  static TextStyle get displayLarge =>
      _base.copyWith(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -1.5);
  static TextStyle get displayMedium =>
      _base.copyWith(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.0);
  static TextStyle get displaySmall =>
      _base.copyWith(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.5);

  // Headline — screen titles
  static TextStyle get headlineLarge =>
      _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static TextStyle get headlineMedium =>
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.3);
  static TextStyle get headlineSmall =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w600);

  // Title — card headers, section headers
  static TextStyle get titleLarge =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get titleMedium =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get titleSmall =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  // Body — general content
  static TextStyle get bodyLarge =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get bodySmall =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  // Label — chips, badges, buttons
  static TextStyle get labelLarge =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1);
  static TextStyle get labelMedium =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5);
  static TextStyle get labelSmall =>
      _base.copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5);

  // Mono — amounts, percentages
  static TextStyle get monoLarge =>
      _base.copyWith(fontFamily: 'RobotoMono', fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle get monoMedium =>
      _base.copyWith(fontFamily: 'RobotoMono', fontSize: 16, fontWeight: FontWeight.w500);
}
