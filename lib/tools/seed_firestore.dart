import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../features/hotels/data/datasources/hotel_catalogue_seeder.dart';
import '../features/hotels/data/datasources/hotel_seed_catalog.dart';
import '../firebase_options.dart';

/// A developer tool, not part of the shipped app.
///
/// Run it with:
///   flutter run -d chrome -t lib/tools/seed_firestore.dart
///
/// It writes [HotelSeedCatalog] into the `hotels` collection through the
/// client SDK, which means no service-account key is needed — but it also
/// means the Firestore rules must permit writes while it runs. Open the write
/// window, seed, then restore `firestore.rules`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();

  runApp(const _SeederApp());
}

class _SeederApp extends StatelessWidget {
  const _SeederApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catalogue seeder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _SeederPage(),
    );
  }
}

class _SeederPage extends StatefulWidget {
  const _SeederPage();

  @override
  State<_SeederPage> createState() => _SeederPageState();
}

class _SeederPageState extends State<_SeederPage> {
  /// Seeding runs on open so the tool needs no interaction to do its job; the
  /// button is there to re-run it after a rules change.
  _SeedOutcome _outcome = const _SeedOutcome.running();

  @override
  void initState() {
    super.initState();
    _seed();
  }

  Future<void> _seed() async {
    setState(() => _outcome = const _SeedOutcome.running());
    try {
      final written = await getIt<HotelCatalogueSeeder>().seed();
      if (!mounted) return;
      setState(() => _outcome = _SeedOutcome.success(written));
    } catch (error) {
      if (!mounted) return;
      setState(() => _outcome = _SeedOutcome.failure(error.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hotel catalogue seeder', style: textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Writes ${HotelSeedCatalog.hotels.length} documents into the '
                  'hotels collection of booking-mochup. Documents are keyed by '
                  'slug, so re-running updates them in place.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _OutcomeCard(outcome: _outcome),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton.icon(
                  onPressed: _outcome.isRunning ? null : _seed,
                  icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                  label: const Text('Seed again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({required this.outcome});

  final _SeedOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final (icon, colour, title) = switch (outcome) {
      _SeedOutcome(isRunning: true) => (
          Icons.hourglass_top_rounded,
          AppColors.blue,
          'Writing documents…',
        ),
      _SeedOutcome(documentsWritten: final count?) => (
          Icons.check_circle_rounded,
          AppColors.success,
          'Wrote $count documents',
        ),
      _ => (
          Icons.error_outline_rounded,
          AppColors.danger,
          'Seeding failed',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colour),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (outcome.error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  SelectableText(
                    outcome.error!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeedOutcome {
  const _SeedOutcome.running()
      : isRunning = true,
        documentsWritten = null,
        error = null;

  const _SeedOutcome.success(this.documentsWritten)
      : isRunning = false,
        error = null;

  const _SeedOutcome.failure(this.error)
      : isRunning = false,
        documentsWritten = null;

  final bool isRunning;
  final int? documentsWritten;
  final String? error;
}
