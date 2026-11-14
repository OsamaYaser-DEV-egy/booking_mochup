import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The navy band at the top of every screen: wordmark, account actions and
/// the vertical switcher.
///
/// The switcher collapses to a scrollable row on narrow viewports rather than
/// being hidden, so the same navigation is reachable on a phone.
class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({super.key, this.showVerticals = true});

  final bool showVerticals;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.formFactor.isCompact;

    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? AppSpacing.lg : AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.maxContentWidth,
                ),
                child: const _TopRow(),
              ),
            ),
          ),
          if (showVerticals)
            Padding(
              padding: EdgeInsets.only(
                left: isCompact ? AppSpacing.lg : AppSpacing.xxl,
                right: isCompact ? AppSpacing.lg : AppSpacing.xxl,
                bottom: AppSpacing.md,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.maxContentWidth,
                  ),
                  child: const _VerticalSwitcher(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow();

  @override
  Widget build(BuildContext context) {
    final isCompact = context.formFactor.isCompact;

    return Row(
      children: [
        const _Wordmark(),
        const Spacer(),
        if (!isCompact) ...[
          const _HeaderTextAction(label: 'EGP'),
          const SizedBox(width: AppSpacing.xs),
          const _HeaderIconAction(
            icon: Icons.language_rounded,
            tooltip: 'Choose your language',
          ),
          const SizedBox(width: AppSpacing.xs),
          const _HeaderIconAction(
            icon: Icons.help_outline_rounded,
            tooltip: 'Help and support',
          ),
          const SizedBox(width: AppSpacing.sm),
          const _HeaderTextAction(label: 'List your property'),
          const SizedBox(width: AppSpacing.sm),
          const _HeaderOutlinedAction(label: 'Register'),
          const SizedBox(width: AppSpacing.sm),
          const _HeaderOutlinedAction(label: 'Sign in'),
        ] else ...[
          const _HeaderIconAction(
            icon: Icons.favorite_border_rounded,
            tooltip: 'Saved properties',
          ),
          const _HeaderIconAction(
            icon: Icons.account_circle_outlined,
            tooltip: 'Your account',
          ),
          const _HeaderIconAction(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
          ),
        ],
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.amber,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.bed_rounded,
            size: 17,
            color: AppColors.navyDark,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Stayward',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                letterSpacing: -0.5,
              ),
        ),
      ],
    );
  }
}

class _VerticalSwitcher extends StatelessWidget {
  const _VerticalSwitcher();

  static const List<({IconData icon, String label, bool isActive})> _verticals =
      [
    (icon: Icons.bed_rounded, label: 'Stays', isActive: true),
    (icon: Icons.flight_rounded, label: 'Flights', isActive: false),
    (icon: Icons.directions_car_rounded, label: 'Car rentals', isActive: false),
    (icon: Icons.attractions_rounded, label: 'Attractions', isActive: false),
    (
      icon: Icons.local_taxi_rounded,
      label: 'Airport taxis',
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final vertical in _verticals) ...[
            _VerticalTab(
              icon: vertical.icon,
              label: vertical.label,
              isActive: vertical.isActive,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _VerticalTab extends StatelessWidget {
  const _VerticalTab({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isActive,
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? AppColors.navyLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isActive ? Colors.white54 : Colors.white24,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderTextAction extends StatelessWidget {
  const _HeaderTextAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child: Text(label),
    );
  }
}

class _HeaderIconAction extends StatelessWidget {
  const _HeaderIconAction({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      tooltip: tooltip,
      icon: Icon(icon, color: Colors.white, size: 20),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _HeaderOutlinedAction extends StatelessWidget {
  const _HeaderOutlinedAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54, width: 1.2),
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      child: Text(label),
    );
  }
}
