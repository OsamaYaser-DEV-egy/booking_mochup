import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

/// The root widget: theme and routing, and nothing else.
class StaywardApp extends StatefulWidget {
  const StaywardApp({super.key});

  @override
  State<StaywardApp> createState() => _StaywardAppState();
}

class _StaywardAppState extends State<StaywardApp> {
  // Built once and held, because rebuilding the router would reset navigation
  // history on every theme or locale change.
  final _router = AppRouter.create();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Stayward — find your next stay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
