# Stayward

A stay-search application in the spirit of the large booking sites, built once
in Flutter and shipped as a **website, an Android app and an iOS app** from a
single codebase. The visual language is deliberately adjacent to the familiar
travel-booking look — navy header, amber search bar, blue property titles, the
square guest-score badge — but the palette is softened: a lighter, slightly
indigo navy, a warmer action blue and an amber rather than a saturated yellow,
so large surfaces stay comfortable to read.

Data is served from **Cloud Firestore** (project `booking-mochup`), seeded with
five mocked Egyptian properties.

---

## What the screen does

The search-results screen is fully interactive, not a static mock:

- **Search** by destination, with a date-range picker and a stepper-based
  occupancy editor (adults, children, rooms, pets).
- **Filter** by nightly budget, popular shortcuts, review score, property type,
  star rating, facilities and distance from the centre. Every group shows live
  counts computed against the *other* active filters, and a group with no
  matches is disabled rather than offered as a dead end.
- **Sort** by top picks, price, review score, property rating or distance.
  "Top picks" blends guest score, review volume and partner status, so a
  well-reviewed property with thousands of reviews outranks a thinly-reviewed
  one with a marginally higher score.
- **Remove** any filter from a chip row above the results, or clear them all.
- **Save** a property to a local shortlist.

Behaviour that matters:

- A filter change **refreshes** rather than reloads — the current results stay
  on screen and dim instead of flashing empty on every checkbox tick.
- A first load shows skeletons shaped like the real cards, so nothing jumps.
- A failure, an empty destination and a filtered-out list are three distinct
  states with three distinct messages.
- A dead image URL degrades into a deliberate placeholder, never a broken glyph.

### Responsive behaviour

| Width | Layout |
| --- | --- |
| `< 760` (compact) | Stacked cards, icon-only header actions, sort as a menu, filters in a bottom sheet |
| `760–1139` (medium) | Horizontal cards, filters still in a sheet |
| `>= 1140` (expanded) | Persistent 260 px filter rail, segmented sort bar |

---

## Architecture

Clean architecture with a strict dependency rule: **outer layers depend on
inner ones, never the reverse.** The domain layer imports nothing from Flutter,
Firebase or the data layer.

```
lib/
├── app/                        MaterialApp: theme and routing, nothing else
├── core/
│   ├── config/                 dart-define flags, in one place
│   ├── di/                     get_it + injectable container
│   ├── error/                  Failure (domain) and AppException (data)
│   ├── responsive/             Breakpoints and FormFactor
│   ├── router/                 go_router route table
│   ├── theme/                  Colour, spacing, radius, shadow, type tokens
│   ├── usecase/                UseCase contracts
│   └── utils/                  Shared formatters
└── features/hotels/
    ├── domain/                 ← depends on nothing
    │   ├── entities/           Hotel aggregate and its value objects
    │   ├── repositories/       HotelRepository contract
    │   ├── services/           HotelFilter, HotelSorter, FacetCalculator
    │   └── usecases/           SearchHotels, GetHotelDetails
    ├── data/                   ← depends on domain
    │   ├── dtos/               Wire format + a fail-loud MapReader
    │   ├── datasources/        Firestore source, in-memory source, seeder
    │   ├── mappers/            DTO → entity translation
    │   └── repositories/       HotelRepositoryImpl
    └── presentation/           ← depends on domain
        ├── cubit/              SearchCubit and SearchState
        ├── pages/              SearchResultsPage
        └── widgets/            Card, rail, panel, sort bar, status views
```

### How SOLID shows up here

**Single responsibility.** `SearchCubit` records what the user chose and
publishes outcomes — it holds no filtering or ordering rules, which is why it
stays short regardless of how many filters exist. Narrowing lives in
`HotelFilter`, ordering in `HotelSorter`, counting in `FacetCalculator`, and
exception-to-failure translation is the *entire* job of
`HotelRepositoryImpl`.

**Open/closed.** A new filter is a new `HotelCriterion` class; a new ordering is
a new `Comparator` plus one case in a lookup. Neither requires editing an
existing rule. `UseCase<Output, Input>` means new behaviour arrives as a new
use case rather than a widened existing one.

**Liskov.** `InMemoryHotelDataSource` and `FirestoreHotelDataSource` are
interchangeable behind `HotelRemoteDataSource` — they normalise destination
tokens identically, so swapping one for the other changes latency and nothing
else.

**Interface segregation.** `HotelRepository` exposes exactly two methods, both
about retrieval. Filtering, sorting and faceting are not on it, because no
caller needs storage and business rules through the same door.

**Dependency inversion.** The domain declares `HotelRepository`; the data layer
implements it. Every collaborator arrives through a constructor — nothing
reaches for the service locator at runtime — so each class can be built
directly in a test with plain fakes.

### Error handling

Data sources throw `AppException` subtypes. `HotelRepositoryImpl` catches them
and returns `Either<Failure, T>`. Above the data layer, no infrastructure
exception type is visible — the presentation layer pattern-matches on sealed
`Failure` variants to pick an icon and a headline.

---

## Running it

### Prerequisites

Flutter 3.47 or newer.

```bash
flutter pub get
```

Generated DI code is committed; regenerate it after changing an `@injectable`
annotation:

```bash
dart run build_runner build
```

### Against the bundled catalogue (no Firebase needed)

Useful offline, and for working on the UI without network latency.

```bash
flutter run -d chrome --dart-define=USE_LOCAL_CATALOGUE=true
```

### Against Firestore

```bash
flutter run -d chrome
```

```bash
flutter run -d android
```

```bash
flutter run -d ios
```

### Tests

```bash
flutter test
```

---

## Firebase

The project is `booking-mochup`. Web, Android and iOS apps are registered and
`lib/firebase_options.dart` is generated by the FlutterFire CLI.

### Firestore

Properties live in the `hotels` collection, keyed by a readable slug such as
`horizon-pyramids-view-suites`. Each document carries a `searchTokens` array of
lower-cased destination terms (`egypt`, `giza`, `al haram`, …), which the
destination query matches with `arrayContains`. Array fields are indexed
automatically, so no composite index is required.

Security rules (`firestore.rules`) make the catalogue **publicly readable and
not writable**. The app never writes to Firestore at runtime.

### Seeding

`lib/features/hotels/data/datasources/hotel_seed_catalog.dart` is the single
source of truth for the mocked data — the Firestore seeder writes it and the
in-memory data source serves it, so the two can never drift apart.

Seeding runs through the client SDK, which needs no service-account key but
does need a temporary write window:

1. In `firestore.rules`, change the `hotels` write rule to
   `allow write: if request.time < timestamp.date(YYYY, MM, DD);`
2. `firebase deploy --only firestore:rules`
3. `flutter run -d chrome -t lib/tools/seed_firestore.dart` — it seeds on open
   and reports how many documents it wrote.
4. Restore the `allow write: if false;` rule and deploy again.

Documents are written with `set` and keyed by slug, so re-running updates them
in place rather than duplicating.

### A note on the committed config

`lib/firebase_options.dart` and `android/app/google-services.json` are
committed. The API keys in them are **client identifiers, not secrets** — they
are shipped in every web bundle and app binary by design, and Firebase expects
them to be public. What protects the data is the security rules above, not the
keys.

---

## Deliberate limitations

These are scoped out, not overlooked:

- The map is a styled placeholder; no tile provider is wired up.
- The saved-properties shortlist is in-memory — persisting it needs accounts.
- The results list is built eagerly, which is right for five properties. A
  paginated catalogue would move it to a sliver list fed by the cubit.
- Currency, language and the account actions in the header are presentational.
- Inter is fetched at runtime by `google_fonts`; it falls back cleanly when
  offline. Bundling the font would remove the first-paint dependency.
