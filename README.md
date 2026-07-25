# RehabFlow

Rehabilitation Exercise Management Application built with Flutter and GetX.

> Incremental development across 10 phases. Full documentation lands in Phase 10.

## Setup

```bash
flutter pub get
flutter run
```

## Architecture (planned)

Feature-level clean structure with GetX:

```
lib/
  core/          # constants, theme, routes, bindings, storage, widgets
  network/       # API client & connectivity
  utils/         # validators, responsive helpers
  features/
    auth/
    exercises/
    favorites/
```

## State management

**GetX** — reactive controllers, DI via bindings, and declarative routing.
