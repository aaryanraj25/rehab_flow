# RehabFlow

A Flutter app that helps people browse and manage rehabilitation exercises even when they are offline.

* You log in with a mock account
* You browse a dashboard full of exercises
* You search by name and filter by category, difficulty, and target muscle all at the same time
* You open any exercise to see the full details and a large image
* You save exercises to favorites and they stay saved
* Everything keeps working even without internet

---

## Project Setup Instructions

* Make sure you have the latest stable Flutter SDK installed
* Run these commands from the project folder

```bash
flutter pub get
flutter run
```

* To build an APK for testing, run

```bash
flutter build apk --release
```

* The APK will show up under `build/app/outputs/flutter-apk/app-release.apk`

### Logging in

* There is no real backend behind login, so any email that looks like a real email will work
* For the password, just use six characters or more
* That is all it takes to get in

### Demo account

* Email: `demo@rehabflow.com`
* Password: `demo123`
* You can also just type your own email and any six-character password since login is fully mocked

---

## Architecture Used

* The app follows a feature-first layout
* Each feature like auth, exercises, or favorites has its own data layer and its own presentation layer
* The data layer talks to Hive and to the network
* The presentation layer is what the user actually sees and taps on
* A screen never talks to Hive or Dio directly — it always goes through a controller and a repository
* This keeps things clean and easy to follow even months later
* The app follows clean architecture principles with a clear separation between data and presentation for every feature
* The layering that is here is applied the same way across every feature so nothing feels bolted on

---

## Folder Structure

```
rehab_flow/
lib/
  main.dart
  core/
    bindings/
    constants/
    di/
    errors/
    routes/
    storage/
    theme/
    widgets/
  network/
  utils/
  features/
    auth/
      data/
      presentation/
    exercises/
      data/
      presentation/
    favorites/
      data/
      presentation/
assets/
  data/exercises.json
  branding/app_icon.png
test/
integration_test/
android/
ios/
pubspec.yaml
README.md
```

---

## State Management Approach

* GetX handles the reactive state, the navigation, and most of the wiring between screens
* Controllers hold the observable state and screens just listen and rebuild
* Repositories are constructed through a small service locator so nothing is hard-wired together
* A favorites controller lives for the whole life of the app so a heart you tap on one screen updates everywhere else instantly
* GetX was picked because it gives state management, dependency injection, and routing in one place
* That saved a lot of setup time without giving up structure
* The project itself is small and simple, so a heavier solution like Bloc would have added more boilerplate than the app actually needed

---

## Packages / Libraries Used

* `get` gives us state management, dependency injection, and navigation
* `dio` handles talking to the exercise API
* `hive` and `hive_flutter` store everything locally in a fast and typed way
* `connectivity_plus` tells the app when it is online or offline
* `flutter_screenutil` keeps sizing consistent across phones and tablets
* `cached_network_image` and `flutter_cache_manager` load and cache exercise images
* `cupertino_icons` gives us a few iOS-style icons
* `flutter_lints`, `hive_generator`, `build_runner`, `integration_test`, `network_image_mock`, and `flutter_launcher_icons` are dev-only tools for linting, code generation, testing, and the app icon
* A dependency override pins `objective_c` to version `9.3.0` to work around a crash in an iOS plugin
* Hive was chosen over SharedPreferences because it is faster and stores real typed objects instead of just strings
* Hive was chosen over SQLite or Isar because this app does not need complex queries or relational data
* Auth sessions, exercises, and favorites all live in their own Hive boxes so each one can be managed and cleared on its own

---

## Assumptions Made

* The password rule is simply six characters or more — there is no real account system behind it
* Any email that is shaped like a real email is accepted since there is no backend checking it
* The bundled exercise file is what the app leans on when the network truly cannot be reached on first load
* Filtering by category, difficulty, and muscle all combine together so picking more filters narrows the results rather than widening them
* Selecting more than one option inside a single filter (like two categories at once) still works like an either-or match within that one filter
* Favorites are saved as full exercise snapshots so a favorite still shows all its details even if you never open it again while offline
* Related exercises on the detail screen are a nice extra the assignment listed as optional, and they were included

---

## Trade-offs

* On first load the app tries the real API and falls back to Hive or the bundled file if that fails, so it stays usable at all times — but a true “API down” error is rare on a cold start; it only shows up clearly when you pull to refresh or tap retry
* Exercise images are cached to disk only after you have actually seen them once, so opening the app offline before ever seeing a certain image will show a branded placeholder instead of the real photo

---

* Every core requirement in the assignment works end to end
* Authentication, search, filtering, details, favorites, offline support, error handling, and responsive layouts for phones and tablets are all wired through real working code rather than placeholders
