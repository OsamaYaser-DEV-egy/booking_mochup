import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A row of stars describing a property's official rating.
class StarRating extends StatelessWidget {
  const StarRating({
    required this.rating,
    super.key,
    this.size = 14,
    this.color = AppColors.star,
  });

  /// 0–5. A rating of 0 renders nothing, because an unrated property should
  /// not display an empty row of outlines.
  final int rating;

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (rating <= 0) return const SizedBox.shrink();

    return Semantics(
      label: '$rating star property',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          rating,
          (_) => Icon(Icons.star_rounded, size: size, color: color),
        ),
      ),
    );
  }
}
