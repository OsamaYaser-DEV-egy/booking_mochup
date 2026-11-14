/// A 4-point spacing scale. Widgets must use these tokens instead of raw
/// numbers so rhythm stays consistent across breakpoints.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 56;
}

/// Corner radii tokens.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;
}

/// Layout constants shared by the responsive shells.
abstract final class AppLayout {
  /// Maximum width of the centred content column on large screens.
  static const double maxContentWidth = 1232;

  /// Width of the filter rail on desktop.
  static const double filterRailWidth = 260;

  /// Height of the primary application header on desktop.
  static const double headerHeight = 64;
}
