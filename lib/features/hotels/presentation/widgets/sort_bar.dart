import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/sort_option.dart';

/// Ordering controls above the result list.
///
/// On wide viewports every ordering is a visible segment; on narrow ones the
/// same set collapses into a single menu, so the list keeps the full width.
class SortBar extends StatelessWidget {
  const SortBar({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final SortOption selected;
  final ValueChanged<SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    if (context.formFactor.isExpanded) {
      return _SegmentedSortBar(selected: selected, onChanged: onChanged);
    }
    return _SortMenuButton(selected: selected, onChanged: onChanged);
  }
}

class _SegmentedSortBar extends StatelessWidget {
  const _SegmentedSortBar({required this.selected, required this.onChanged});

  final SortOption selected;
  final ValueChanged<SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Sort by:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final option in SortOption.values) ...[
              _SortSegment(
                option: option,
                isSelected: option == selected,
                onPressed: () => onChanged(option),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class _SortSegment extends StatelessWidget {
  const _SortSegment({
    required this.option,
    required this.isSelected,
    required this.onPressed,
  });

  final SortOption option;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blueSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected ? AppColors.blue : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            option.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? AppColors.blueHover : AppColors.inkMuted,
                ),
          ),
        ),
      ),
    );
  }
}

class _SortMenuButton extends StatelessWidget {
  const _SortMenuButton({required this.selected, required this.onChanged});

  final SortOption selected;
  final ValueChanged<SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      initialValue: selected,
      onSelected: onChanged,
      tooltip: 'Change the ordering',
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final option in SortOption.values)
          PopupMenuItem(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: option == selected
                      ? AppColors.blue
                      : AppColors.inkSubtle,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(option.label),
              ],
            ),
          ),
      ],
      child: _ToolbarButton(
        icon: Icons.swap_vert_rounded,
        label: 'Sort',
        detail: selected.label,
      ),
    );
  }
}

/// Shared look for the compact toolbar actions (sort, filter, map).
class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.blue),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.titleSmall?.copyWith(color: AppColors.blue),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The compact-layout button that opens the filter sheet.
class FilterSheetButton extends StatelessWidget {
  const FilterSheetButton({
    required this.activeCount,
    required this.onPressed,
    super.key,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: _ToolbarButton(
        icon: Icons.tune_rounded,
        label: 'Filter',
        detail: activeCount == 0 ? 'None applied' : '$activeCount applied',
      ),
    );
  }
}
