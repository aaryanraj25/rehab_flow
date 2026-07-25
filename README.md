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
flutter test
```

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
| `core/` | Theme, routes, bindings, storage, shared state widgets |
| `network/` | Dio client + connectivity |
| `utils/` | Validators + responsive / ScreenUtil helpers |

Repositories own persistence and networking. Controllers stay thin and reactive. Shared UI states (loading / empty / error / offline) live in reusable widgets.

---

## Folder structure

```
lib/
  main.dart
  core/
    bindings/
    constants/
    routes/
    storage/
    theme/
    widgets/          # loading, empty, error, offline banner
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

**GetX** was chosen because it covers the assignment needs in one cohesive toolkit:

1. **Reactive UI** via `.obs` / `Obx` for lists, filters, favourites, and load states  
2. **DI** through `Get.put` / bindings (controllers + repositories)  
3. **Routing** with `GetMaterialApp` + `GetPage` (splash → login → exercises → detail → favourites)  
4. Low boilerplate relative to Bloc for a medium-sized assignment app, while still keeping feature folders and repository boundaries

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
| `shared_preferences` | Auth session, exercise cache, favourites |
| `connectivity_plus` | Online / offline detection |
| `cached_network_image` | Image loading + disk cache |
| `flutter_screenutil` | Consistent scaling on phones/tablets |

---

## Features mapped to requirements

1. **Authentication** — email/password validation, mock login, local session, auto-login  
2. **Exercise dashboard** — name, category, difficulty, target muscle, thumbnail  
3. **Search** — by exercise name  
4. **Filters** — category + difficulty + target muscle (combined with AND)  
5. **Details** — large image, description, instructions, equipment, related exercises  
6. **Favourites** — add/remove + local persistence + favourites screen  
7. **Offline** — caches exercise list, details, and favourite ids; serves cache/asset when offline  
8. **Error handling** — loading, empty, API/cache failure, offline banner, retry  
9. **Responsive UI** — ScreenUtil + breakpoints for phone list vs tablet grids / wide login  

---

## Assumptions

- Mock auth is intentional (assignment: no real backend required).  
- Bundled `assets/data/exercises.json` is the primary content source for reliable demos; a public GitHub raw URL can refresh on pull-to-refresh when online.  
- Images come from public Unsplash URLs; offline still shows text/data (images may fall back to placeholders).  
- Favourites store exercise **ids**; resolving titles/images uses the local exercise cache/asset.  

---

## Trade-offs

- **GetX vs Bloc/Riverpod** — faster delivery and fewer files; stricter compile-time DI is traded for convention-based GetX registration.  
- **SharedPreferences vs Hive/SQLite** — enough for JSON list cache + id lists; a local DB would scale better for large datasets.  
- **Asset-first data** — guarantees offline/demo reliability; remote API is secondary refresh, not a hard dependency.  
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
