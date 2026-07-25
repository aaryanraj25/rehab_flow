# RehabFlow

Rehabilitation Exercise Management Application built with **Flutter** and **GetX**.

Browse rehab exercises, search/filter them, view details, mark favourites, and keep using the app offline with locally cached data.

---

## Project setup

### Prerequisites

- Flutter stable (tested with **3.38.x** / Dart **3.10.x**)
- Android Studio / Xcode (optional, for device/emulator runs)

### Run

```bash
cd rehab_flow
flutter pub get
flutter run
```

### Demo login (mock auth)

Any valid email + password (min 6 characters) works.

Example:

- Email: `demo@rehabflow.app`
- Password: `rehab123`

Session is persisted locally; relaunching the app auto-logs in when a session exists.

### Tests

```bash
# Unit + widget + host integration flows
flutter test

# Device/emulator integration binding smoke test
flutter test integration_test -d <deviceId>
```

Coverage layout:

- `test/unit/` — validators, exceptions, models, repositories, controllers, Hive storage
- `test/widget/` — splash, login, exercise list UI
- `test/integration/` — browse/search, favourites resolution, detail UI (host, no device)
- `integration_test/` — device binding smoke test for hardware runs

### Optional APK

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Architecture used

**Feature-first clean separation** with GetX for presentation state:

| Layer | Responsibility |
|--------|----------------|
| `presentation/` | Screens, controllers, feature widgets |
| `data/` | Models + repositories (auth, exercises, favourites) |
| `core/` | Theme, routes, bindings, `di/`, storage, shared state widgets |
| `network/` | Dio client + connectivity |
| `utils/` | Validators + responsive / ScreenUtil helpers |

Repositories own persistence and networking behind abstract contracts
(`AuthRepository`, `ExerciseRepository`, `FavoritesRepository`) with Hive-backed
`*Impl` classes. `ServiceLocator.registerCore()` constructs them with
**constructor injection**, then registers singletons for presentation lookup.
Controllers stay thin and reactive. Shared UI states (loading / empty /
offline vs API error / retry) live in reusable widgets.

---

## Folder structure

```
lib/
  main.dart
  core/
    bindings/
    constants/
    di/               # ServiceLocator (constructor DI + GetX registration)
    routes/
    storage/
    theme/
    widgets/          # loading, empty, offline/API error, retry
  network/
  utils/              # validators, responsive + ScreenUtil
  features/
    auth/
      data/{models,repositories}
      presentation/{controllers,screens,widgets}
    exercises/
      data/{models,repositories}
      presentation/{controllers,screens,widgets}
    favorites/
      data/repositories
      presentation/{controllers,screens,widgets}
assets/
  data/exercises.json # bundled mock dataset + offline fallback
```

---

## State management approach

**GetX** covers presentation needs; data deps are constructor-injected:

1. **Reactive UI** via `.obs` / `Obx` for lists, filters, favourites, and load states  
2. **Constructor DI** in `ServiceLocator` / bindings — repositories take storage/API/network via constructors; GetX only stores the resulting singletons  
3. **Routing** with `GetMaterialApp` + `GetPage` (splash → login → exercises → detail → favourites)  
4. Low boilerplate relative to Bloc, while keeping feature folders and repository boundaries

Controllers:

- `AuthController` / `SplashController`
- `ExerciseController` (list, search, filters)
- `ExerciseDetailController`
- `FavoritesController`

---

## Packages / libraries used

| Package | Why |
|---------|-----|
| `get` | State management, DI, navigation |
| `dio` | REST client |
| `hive` / `hive_flutter` | Auth session, typed exercise cache, favourites (fast key-value + typed objects; more scalable than SharedPreferences for structured data, still lighter than SQLite/Isar for this app) |
| `connectivity_plus` | Online / offline detection |
| `cached_network_image` | Image loading + disk cache |
| `flutter_cache_manager` | Custom offline image cache + prefetch |
| `flutter_screenutil` | Consistent scaling on phones/tablets |
| `cupertino_icons` | iOS-style icon font (Flutter default) |

---

## Features mapped to requirements

1. **Authentication** — email/password validation, mock login, local session, auto-login  
2. **Exercise dashboard** — name, category, difficulty, target muscle, thumbnail  
3. **Search** — by exercise name  
4. **Filters** — category + difficulty + target muscle (combined with AND)  
5. **Details** — large image, description, instructions, equipment, related exercises  
6. **Favourites** — add/remove + local persistence + favourites screen  
7. **Offline** — caches exercise list, details, and favourite **snapshots**; serves Hive/API/asset when offline  
8. **Error handling** — loading, empty, distinct offline vs API failure screens, retry (pull-to-refresh hard-fails into `AppErrorView`)  
9. **Responsive UI** — ScreenUtil + breakpoints for phone list vs tablet grids / wide login  

---

## Assumptions

- Mock auth is intentional (assignment: no real backend required).  
- Online loads are **REST-first** (`exercisesApiUrl`); Hive cache then bundled `assets/data/exercises.json` are fallbacks if the first load’s API call fails.  
- **Pull-to-refresh / Retry** re-hits the API with `forceRefresh: true`. If that fails, the app shows the hard `AppErrorView` (not a silent soft-fail).  
- Flip `AppConstants.debugForceApiHardFailure` to `true` to force `AppErrorView` on every load without cutting the network.  
- Images come from public Unsplash URLs; offline still shows text/data (images may fall back to placeholders after prefetch).  
- Favourites store full **`ExerciseModel` snapshots** in Hive (not ids alone), so the favourites screen works offline even if the main exercise cache changes.  
- Local persistence uses **Hive** (auth, exercises, favourites snapshots, exercise-id index) with TypeAdapters for `UserModel` and `ExerciseModel`.

---

## Trade-offs

- **GetX for presentation + constructor DI for data** — repositories/controllers are wired in `ServiceLocator` / bindings with constructor injection; GetX holds singletons for `GetView` lookup (not a free-for-all service locator in the data layer).  
- **Hive vs SharedPreferences/SQLite** — typed adapters and better scaling for structured caches than SharedPreferences; lighter than SQLite/Isar for this dataset.  
- **Initial-load soft fallback** — if the first online API call fails, cache/asset still populate the list with a refresh-failed banner so demos aren’t blocked; explicit refresh/retry uses the hard error screen.  
- **iOS `objective_c` pin** — temporary `dependency_overrides` to avoid a known plugin crash on newer `objective_c` builds.

---

## Responsive notes

- Design size: **390 × 844** (`flutter_screenutil`)  
- Phone: compact exercise cards (list)  
- Tablet: multi-column grids, wider content max-width, split login on wide canvases  
- Breakpoints in `lib/utils/responsive.dart`

---

## License

Assignment / evaluation project — not published to pub.dev (`publish_to: none`).
