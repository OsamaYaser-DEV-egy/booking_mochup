import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'firebase_options.dart';

/// Application entry point.
///
/// Composition order matters: Firebase must be ready before the service
/// locator resolves anything that depends on it, and the locator must be ready
/// before the first screen asks for a cubit. Initialising Firebase is skipped
/// entirely when the app runs against the bundled catalogue, so a local run
/// needs no Firebase project at all.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.useLocalCatalogue) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await configureDependencies();

  runApp(const StaywardApp());
}
