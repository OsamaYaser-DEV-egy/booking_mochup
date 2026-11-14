import 'package:flutter/material.dart';

/// Elevation is expressed through a small set of named shadows rather than
/// Material's numeric elevation, so cards look identical on web and mobile.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14101828),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x1F101828),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> searchBar = [
    BoxShadow(
      color: Color(0x33101828),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];
}
