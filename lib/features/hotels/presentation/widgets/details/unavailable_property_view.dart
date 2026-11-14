import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../search_status_views.dart';

/// Shown when the property page is opened without a property.
///
/// The details screen is presentation only: it renders a hotel the results
/// list hands it and never fetches one. A cold link therefore has nothing to
/// show, so this view says so plainly and offers the way back.
class UnavailablePropertyView extends StatelessWidget {
  const UnavailablePropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SearchStatusView(
            icon: Icons.open_in_browser_rounded,
            title: 'Open this property from the results',
            message: 'Property pages are opened from the search results. '
                'Head back and pick a stay to see it here.',
            action: FilledButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to search results'),
            ),
          ),
        ),
      ),
    );
  }
}
