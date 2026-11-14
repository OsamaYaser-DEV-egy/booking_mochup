import 'package:go_router/go_router.dart';

import '../../features/hotels/presentation/pages/search_results_page.dart';

/// The application's route table.
///
/// go_router is used so the web build gets real, shareable URLs and the
/// browser's back button behaves, while the same routes drive navigation on
/// mobile.
abstract final class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: SearchResultsPage.routePath,
      routes: [
        GoRoute(
          path: SearchResultsPage.routePath,
          name: SearchResultsPage.routeName,
          builder: (_, _) => const SearchResultsPage(),
        ),
      ],
    );
  }
}
