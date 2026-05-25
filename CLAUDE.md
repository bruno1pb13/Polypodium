# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Polypodium** — Flutter mobile app for plant care tracking. Offline-first; no network calls exist yet. Future sync layer will use the `sync_queue` table and `syncStatus` fields already present on every entity.

## Build Commands

```bash
# First-time setup
flutter pub get

# Generate Drift (database) and Riverpod (providers) code — required before first build
dart run build_runner build --delete-conflicting-outputs

# Incremental watch mode during development
dart run build_runner watch --delete-conflicting-outputs

# Run on connected device/emulator
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test.dart
```

> Every time a `@DriftDatabase`, `@DriftAccessor`, or `@riverpod` annotated file is changed, `build_runner` must be re-run (or be running in watch mode) to regenerate the matching `.g.dart` file.

## Architecture

Feature-first with three layers per feature:

```
lib/
├── core/
│   ├── database/       # AppDatabase (Drift), TypeConverters, SyncQueueTable+DAO, DatabaseProvider
│   ├── notifications/  # NotificationService (flutter_local_notifications + WorkManager)
│   ├── storage/        # PhotoStorage (local files via path_provider)
│   ├── theme/          # AppTheme
│   └── enums.dart      # SoilType, EntryType, SyncStatus
├── features/
│   ├── species/
│   │   ├── domain/     # SpeciesModel
│   │   ├── data/       # SpeciesTable, SpeciesDao, SpeciesRepository
│   │   └── presentation/  # providers/, screens/, (no widgets/)
│   ├── plants/
│   │   ├── domain/     # PlantModel, PlantWithSpecies
│   │   ├── data/       # PlantsTable, PlantsDao, PlantsRepository
│   │   └── presentation/  # providers/, screens/, widgets/
│   └── entries/
│       ├── domain/     # EntryModel
│       ├── data/       # EntriesTable, EntriesDao, EntriesRepository
│       └── presentation/  # providers/, screens/, widgets/
└── main.dart
```

## Key Design Decisions

**State management:** Riverpod with code-generation annotations (`@riverpod`, `@Riverpod(keepAlive: true)`). Providers live in `presentation/providers/`. Each feature has a `XxxNotifier` (AsyncNotifier) that exposes CRUD to the UI.

**Database:** Drift 2.x with `@DriftDatabase` on `AppDatabase`. Tables are defined per-feature and listed centrally. DAOs are created as `late final` fields on the database class (not via the annotation's `daos:` list) to avoid circular import issues. Enum columns use `TypeConverter` (see `core/database/converters.dart`).

**Retention policy:** `EntriesRepository.create()` calls `_enforceRetentionPolicy()` after every insert — keeps the 30 newest entries per plant, deletes the rest, and calls `PhotoStorage.cleanOrphanPhotos()`.

**Notifications:** `NotificationService.scheduleIrrigationNotification()` is called by `PlantsRepository` after every `save()` and `irrigate()`. The WorkManager task (`callbackDispatcher` in `main.dart`) calls `NotificationService.checkAndRescheduleAll()` every 12 hours as a safety net.

**Sync preparation:** Every entity has `syncStatus: SyncStatus` (pending/synced/conflict). Every write calls `SyncQueueDao.enqueue()`. Both fields and the `sync_queue` table exist in the DB but are ignored by the UI. All sync integration points are marked `// TODO(sync):`.

## SOLID and Testing Guidelines

All generated code must be testable and follow SOLID principles. These are non-negotiable requirements, not suggestions.

**Testability rules:**
- Every new class that has dependencies must receive them via constructor injection so they can be replaced with mocks in tests.
- Never call static methods of platform-coupled services (notifications, storage, sensors) directly from repositories or notifiers — always go through an interface injected via Riverpod.
- Extract non-trivial pure logic (date calculations, filtering, validation) into standalone functions or methods marked `@visibleForTesting` so they can be unit-tested without initialising Flutter plugins.
- Always write unit tests for new business logic in Repositories and Notifiers.
- Use `mocktail` for mocking dependencies.
- Use `ProviderContainer` for testing Riverpod providers without a widget tree.
- Mock repositories when testing notifiers to isolate logic.
- For database tests, use `NativeDatabase.memory()` and `AppDatabase.forTesting()`.

**SOLID Principles:**
- **S**ingle Responsibility: Keep DAOs focused on raw SQL/mapping, Repositories on domain logic, and Notifiers on UI state.
- **O**pen/Closed: Prefer adding new providers or extending logic via composition rather than modifying complex existing classes.
- **L**iskov Substitution: If using interfaces for repositories, ensure mocks follow the same behavior.
- **I**nterface Segregation: Notifiers should only depend on the specific repositories they need. Platform services (notifications, storage) must expose narrow interfaces — only the methods a given caller needs.
- **D**ependency Inversion: Always use Riverpod providers to inject dependencies. Do not instantiate repositories or services directly inside notifiers or other services. Use `ref.watch` or `ref.read` to obtain dependencies.

## Platform Setup (required before running)

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<!-- WorkManager / exact alarms -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <!-- WorkManager background service -->
<service android:name="androidx.work.impl.background.systemjob.SystemJobService" .../>
```

**Android** (`android/app/build.gradle`): `minSdkVersion 21`

**iOS** (`ios/Runner/AppDelegate.swift`): WorkManager requires `FlutterLocalNotificationsPlugin.setPluginRegistrantCallback` — follow the `workmanager` package README for iOS setup.
