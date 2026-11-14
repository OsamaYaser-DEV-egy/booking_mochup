import 'package:go_router/go_router.dart';

import '../../features/hotels/domain/entities/hotel.dart';
import '../../features/hotels/presentation/pages/hotel_details_page.dart';
import '../../features/hotels/presentation/pages/search_results_page.dart';
import 'stay_context_codec.dart';

/// The application's route table.
///
/// go_router is used so the web build gets real, shareable URLs and the
/// browser's back button behaves, while the same routes drive navigation on
/// mobile.
///
/// The details route carries the already-loaded [Hotel] in `extra` because
/// that screen is presentation only and never fetches. The stay still travels
/// in query parameters so the URL describes what is on screen, but a cold link
/// arrives with no hotel and the page says so rather than guessing.
abstract final class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: SearchResultsPage.routePath,
      routes: [
        GoRoute(
          path: SearchResultsPage.routePath,
          name: SearchResultsPage.routeName,
          builder: (_, _) => const SearchResultsPage(),
          routes: [
            GoRoute(
              path: 'hotel/:hotelId',
              name: HotelDetailsPage.routeName,
              builder: (_, state) {
                final parameters = state.uri.queryParameters;
                return HotelDetailsPage(
                  hotel: state.extra as Hotel?,
                  dates: StayContextCodec.decodeDates(parameters),
                  guests: StayContextCodec.decodeGuests(parameters),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
