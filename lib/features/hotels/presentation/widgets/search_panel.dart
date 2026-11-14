import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/search_query.dart';
import 'guest_selector.dart';

/// The destination, dates and guests form.
///
/// The panel is a self-contained editor: it keeps its own draft of the query
/// and only reports upwards when the user presses Search, so typing a new
/// destination does not re-run the search on every keystroke.
class SearchPanel extends StatefulWidget {
  const SearchPanel({
    required this.query,
    required this.onSubmit,
    super.key,
  });

  final SearchQuery query;
  final ValueChanged<SearchQuery> onSubmit;

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  late final TextEditingController _destinationController;
  late StayDates _dates;
  late GuestSelection _guests;

  @override
  void initState() {
    super.initState();
    _destinationController =
        TextEditingController(text: widget.query.destination);
    _dates = widget.query.dates;
    _guests = widget.query.guests;
  }

  @override
  void didUpdateWidget(SearchPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the draft aligned when the query changes from outside, for example
    // when a deep link opens the screen on a different destination.
    if (oldWidget.query != widget.query) {
      _destinationController.text = widget.query.destination;
      _dates = widget.query.dates;
      _guests = widget.query.guests;
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _submit() {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) return;

    widget.onSubmit(
      widget.query.copyWith(
        destination: destination,
        dates: _dates,
        guests: _guests,
      ),
    );
  }

  Future<void> _pickDates() async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 500)),
      currentDate: firstDate,
      initialDateRange: _dates.isDefined
          ? DateTimeRange(start: _dates.checkIn!, end: _dates.checkOut!)
          : null,
      helpText: 'Select your dates',
      saveText: 'Done',
    );

    if (picked == null || !mounted) return;
    setState(() {
      _dates = StayDates(checkIn: picked.start, checkOut: picked.end);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isStacked = !context.formFactor.isExpanded;

    final fields = <Widget>[
      _PanelField(
        icon: Icons.search_rounded,
        flex: 4,
        isStacked: isStacked,
        child: TextField(
          controller: _destinationController,
          onSubmitted: (_) => _submit(),
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Where are you going?',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      _PanelField(
        icon: Icons.calendar_today_rounded,
        flex: 4,
        isStacked: isStacked,
        onTap: _pickDates,
        child: Text(
          Formatters.dateRange(_dates.checkIn, _dates.checkOut),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _dates.isDefined
                    ? AppColors.ink
                    : AppColors.inkSubtle,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _PanelField(
        icon: Icons.person_outline_rounded,
        flex: 4,
        isStacked: isStacked,
        child: GuestSelectorButton(
          selection: _guests,
          onChanged: (selection) => setState(() => _guests = selection),
        ),
      ),
    ];

    final searchButton = SizedBox(
      height: 48,
      width: isStacked ? double.infinity : null,
      child: FilledButton(
        onPressed: _submit,
        style: FilledButton.styleFrom(
          textStyle: Theme.of(context).textTheme.titleMedium,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        ),
        child: const Text('Search'),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.amber,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: isStacked
          ? Column(
              children: [
                for (final field in fields) ...[
                  field,
                  const SizedBox(height: AppSpacing.xs),
                ],
                searchButton,
              ],
            )
          : Row(
              children: [
                for (final field in fields) ...[
                  Expanded(flex: 4, child: field),
                  const SizedBox(width: AppSpacing.xs),
                ],
                searchButton,
              ],
            ),
    );
  }
}

/// One cell of the search panel: a white box with a leading icon.
class _PanelField extends StatelessWidget {
  const _PanelField({
    required this.icon,
    required this.child,
    required this.flex,
    required this.isStacked,
    this.onTap,
  });

  final IconData icon;
  final Widget child;
  final int flex;
  final bool isStacked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.inkMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Align(alignment: Alignment.centerLeft, child: child)),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: content,
    );
  }
}
