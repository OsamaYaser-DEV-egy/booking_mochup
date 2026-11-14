import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// The semantic weight a tag carries, which decides its colours.
enum TagTone {
  /// Neutral information, e.g. a facility name.
  neutral,

  /// A reassurance, e.g. free cancellation.
  positive,

  /// Scarcity or a deadline, e.g. only two rooms left.
  urgent,

  /// A promotion, e.g. a member discount.
  promotional,

  /// Editorial emphasis, e.g. a preferred-partner mark.
  informative,
}

/// A small pill of metadata shown on property cards.
class FeatureTag extends StatelessWidget {
  const FeatureTag({
    required this.label,
    super.key,
    this.tone = TagTone.neutral,
    this.icon,
  });

  final String label;
  final TagTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(tone);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: palette.foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: palette.foreground),
          ),
        ],
      ),
    );
  }

  _TagPalette _paletteFor(TagTone tone) {
    return switch (tone) {
      TagTone.neutral => const _TagPalette(
          background: AppColors.surfaceMuted,
          border: AppColors.border,
          foreground: AppColors.inkMuted,
        ),
      TagTone.positive => const _TagPalette(
          background: AppColors.successSoft,
          border: Color(0xFFBFE3D5),
          foreground: AppColors.success,
        ),
      TagTone.urgent => const _TagPalette(
          background: AppColors.dangerSoft,
          border: Color(0xFFF5C4C4),
          foreground: AppColors.danger,
        ),
      TagTone.promotional => const _TagPalette(
          background: AppColors.amberSoft,
          border: AppColors.amberBorder,
          foreground: AppColors.warning,
        ),
      TagTone.informative => const _TagPalette(
          background: AppColors.blueSoft,
          border: AppColors.blueBorder,
          foreground: AppColors.blueHover,
        ),
    };
  }
}

class _TagPalette {
  const _TagPalette({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}
