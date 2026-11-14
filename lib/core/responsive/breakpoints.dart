import 'package:flutter/widgets.dart';

/// The three form factors the product is designed for.
enum FormFactor {
  /// Phones, and the narrow end of the browser window.
  compact,

  /// Tablets and split-screen browser windows.
  medium,

  /// Laptops and desktops, where the filter rail is shown inline.
  expanded;

  bool get isCompact => this == FormFactor.compact;
  bool get isMedium => this == FormFactor.medium;
  bool get isExpanded => this == FormFactor.expanded;

  /// True when filters belong in a modal sheet rather than a persistent rail.
  bool get usesFilterSheet => this != FormFactor.expanded;
}

/// Width thresholds, kept in one place so no widget invents its own.
abstract final class Breakpoints {
  static const double medium = 760;
  static const double expanded = 1140;

  static FormFactor of(double width) {
    if (width >= expanded) return FormFactor.expanded;
    if (width >= medium) return FormFactor.medium;
    return FormFactor.compact;
  }
}

extension FormFactorContext on BuildContext {
  /// The form factor for the current layout width.
  ///
  /// This reads [MediaQuery] width, which is correct for both a resized
  /// browser window and a rotated phone.
  FormFactor get formFactor =>
      Breakpoints.of(MediaQuery.sizeOf(this).width);
}
