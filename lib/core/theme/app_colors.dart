import 'package:flutter/material.dart';

/// Single source of truth for every colour in the product.
///
/// The palette is intentionally adjacent to the well-known travel-booking blue,
/// but softened: the navy is lighter and slightly indigo, the action blue is
/// warmer, and the yellow is pulled towards amber so large surfaces stay
/// comfortable to read for long periods.
abstract final class AppColors {
  // ---------------------------------------------------------------- brand
  /// Primary navy used for the global header and primary emphasis.
  static const Color navy = Color(0xFF0F3D73);
  static const Color navyDark = Color(0xFF0A2B52);
  static const Color navyLight = Color(0xFF1B5296);

  /// Interactive blue: links, focus rings, primary call-to-action buttons.
  static const Color blue = Color(0xFF1A73C7);
  static const Color blueHover = Color(0xFF145FA6);
  static const Color blueSoft = Color(0xFFE8F1FB);
  static const Color blueBorder = Color(0xFFBFD8F2);

  /// Amber accent: promotional badges and highlighted savings.
  static const Color amber = Color(0xFFF5A524);
  static const Color amberSoft = Color(0xFFFFF4E0);
  static const Color amberBorder = Color(0xFFF7D9A6);

  // -------------------------------------------------------------- semantic
  static const Color success = Color(0xFF0E8A62);
  static const Color successSoft = Color(0xFFE6F4EF);
  static const Color danger = Color(0xFFD64545);
  static const Color dangerSoft = Color(0xFFFDECEC);
  static const Color warning = Color(0xFFB4690E);
  static const Color warningSoft = Color(0xFFFDF4E3);

  // -------------------------------------------------------------- neutrals
  static const Color ink = Color(0xFF1A1D23);
  static const Color inkMuted = Color(0xFF596273);
  static const Color inkSubtle = Color(0xFF8A93A3);
  static const Color border = Color(0xFFE1E5EB);
  static const Color divider = Color(0xFFEEF1F5);
  static const Color canvas = Color(0xFFF4F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC);
  static const Color overlay = Color(0x66101828);

  /// Star glyphs on property cards.
  static const Color star = Color(0xFFF2B01E);

  // ----------------------------------------------------------------- misc
  static const Color skeletonBase = Color(0xFFE9EDF2);
  static const Color skeletonHighlight = Color(0xFFF6F8FB);
}
