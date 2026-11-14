import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';

/// A titled block of filter controls inside the rail.
class FilterGroup extends StatelessWidget {
  const FilterGroup({
    required this.title,
    required this.children,
    super.key,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

/// A checkbox row with a label and the number of properties it would leave.
class FilterCheckTile extends StatelessWidget {
  const FilterCheckTile({
    required this.label,
    required this.isSelected,
    required this.onChanged,
    super.key,
    this.count,
    this.leading,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  /// How many properties match. A count of zero disables the row, because
  /// offering a tick that yields nothing is a dead end.
  final int? count;

  final Widget? leading;

  bool get _isEnabled => count == null || count! > 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: _isEnabled ? () => onChanged(!isSelected) : null,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: _isEnabled
                  ? (value) => onChanged(value ?? false)
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: _isEnabled ? AppColors.ink : AppColors.inkSubtle,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                Formatters.count(count!),
                style: textTheme.labelSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
