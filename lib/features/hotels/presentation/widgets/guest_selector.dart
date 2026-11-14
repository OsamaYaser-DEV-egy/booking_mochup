import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/search_query.dart';

/// Opens the occupancy editor and shows the current selection.
class GuestSelectorButton extends StatelessWidget {
  const GuestSelectorButton({
    required this.selection,
    required this.onChanged,
    super.key,
  });

  final GuestSelection selection;
  final ValueChanged<GuestSelection> onChanged;

  Future<void> _open(BuildContext context) async {
    final result = await showDialog<GuestSelection>(
      context: context,
      builder: (_) => _GuestSelectorDialog(initial: selection),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selection.summary,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.inkMuted,
          ),
        ],
      ),
    );
  }
}

/// Stepper-based editor for adults, children, rooms and pets.
class _GuestSelectorDialog extends StatefulWidget {
  const _GuestSelectorDialog({required this.initial});

  final GuestSelection initial;

  @override
  State<_GuestSelectorDialog> createState() => _GuestSelectorDialogState();
}

class _GuestSelectorDialogState extends State<_GuestSelectorDialog> {
  late GuestSelection _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Who is travelling?'),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepperRow(
              label: 'Adults',
              value: _draft.adults,
              minimum: 1,
              maximum: 30,
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(adults: value)),
            ),
            const Divider(height: AppSpacing.xxl),
            _StepperRow(
              label: 'Children',
              helperText: 'Aged 0 to 17',
              value: _draft.children,
              minimum: 0,
              maximum: 10,
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(children: value)),
            ),
            const Divider(height: AppSpacing.xxl),
            _StepperRow(
              label: 'Rooms',
              value: _draft.rooms,
              minimum: 1,
              maximum: 30,
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(rooms: value)),
            ),
            const Divider(height: AppSpacing.xxl),
            SwitchListTile.adaptive(
              value: _draft.travellingWithPets,
              onChanged: (value) => setState(
                () => _draft = _draft.copyWith(travellingWithPets: value),
              ),
              title: const Text('Travelling with pets?'),
              subtitle: const Text('Assistance animals are not counted'),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.blue,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_draft),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
    this.helperText,
  });

  final String label;
  final String? helperText;
  final int value;
  final int minimum;
  final int maximum;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.titleMedium),
              if (helperText != null)
                Text(helperText!, style: textTheme.labelSmall),
            ],
          ),
        ),
        _StepButton(
          icon: Icons.remove_rounded,
          tooltip: 'Fewer ${label.toLowerCase()}',
          onPressed: value > minimum ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          tooltip: 'More ${label.toLowerCase()}',
          onPressed: value < maximum ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        foregroundColor: AppColors.blue,
        disabledForegroundColor: AppColors.border,
        side: BorderSide(
          color: onPressed == null ? AppColors.divider : AppColors.blueBorder,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        minimumSize: const Size(36, 36),
      ),
    );
  }
}
