import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Type scale for the product.
///
/// Inter is used because its tall x-height keeps dense property cards legible
/// at small sizes on both web and mobile. The theme is assembled style by
/// style rather than through `GoogleFonts.interTextTheme()`, because that
/// helper returns the decoupled `material_ui` `TextTheme`, which is a
/// different type from the one `ThemeData` expects.
abstract final class AppTypography {
  static TextTheme build() {
    return TextTheme(
      displaySmall: _style(30, FontWeight.w700, height: 1.2),
      headlineLarge: _style(26, FontWeight.w700, height: 1.25),
      headlineMedium: _style(22, FontWeight.w700, height: 1.27),
      headlineSmall: _style(19, FontWeight.w700, height: 1.3),
      titleLarge: _style(17, FontWeight.w700, height: 1.35),
      titleMedium: _style(15, FontWeight.w600, height: 1.4),
      titleSmall: _style(13, FontWeight.w600, height: 1.4),
      bodyLarge: _style(15, FontWeight.w400, height: 1.5),
      bodyMedium: _style(14, FontWeight.w400, height: 1.5),
      bodySmall: _style(
        13,
        FontWeight.w400,
        height: 1.45,
        color: AppColors.inkMuted,
      ),
      labelLarge: _style(14, FontWeight.w600, height: 1.2),
      labelMedium: _style(12, FontWeight.w600, height: 1.2),
      labelSmall: _style(
        11,
        FontWeight.w600,
        height: 1.2,
        color: AppColors.inkMuted,
      ),
    );
  }

  static TextStyle _style(
    double size,
    FontWeight weight, {
    double? height,
    Color color = AppColors.ink,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: size >= 22 ? -0.4 : 0,
    );
  }
}
