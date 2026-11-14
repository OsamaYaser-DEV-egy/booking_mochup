import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// The common frame for every block on the details screen.
///
/// Having one shell means a new section is a title and a child, and spacing,
/// borders and heading weight stay consistent without each section repeating
/// them.
class DetailsSection extends StatelessWidget {
  const DetailsSection({
    required this.child,
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.padded = true,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  /// Set false when the child draws its own edge-to-edge content.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.all(padded ? AppSpacing.xl : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: padded ? 0 : AppSpacing.xl,
                right: padded ? 0 : AppSpacing.xl,
                top: padded ? 0 : AppSpacing.xl,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!, style: textTheme.headlineSmall),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(subtitle!, style: textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          child,
        ],
      ),
    );
  }
}

/// A label/value row used by the house-rules and surroundings blocks.
class DetailsFactRow extends StatelessWidget {
  const DetailsFactRow({
    required this.label,
    required this.value,
    super.key,
    this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.inkMuted),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            flex: 3,
            child: Text(label, style: textTheme.bodyMedium),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: textTheme.titleSmall?.copyWith(color: valueColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
