# Blink Flutter - Copilot Instructions

## Project Overview
**Blink** is a Flutter dating app using **clean architecture** with **Riverpod** for state management, **Hive** for offline-first local storage, and **Dio** for networking. The codebase supports offline functionality with automatic online/offline sync.

## Architecture & Structure

### Clean Architecture Layers
- **Presentation** (`lib/features/{feature}/presentation/`): UI screens, pages, view models, and state management
- **Domain** (`lib/features/{feature}/domain/`): Business logic, entities, repositories (interfaces), and use cases
- **Data** (`lib/features/{feature}/data/`): Repositories (implementations), data sources (local/remote), and models

### Feature Organization
Each feature (e.g., `auth`, `item`) follows:
```
lib/features/{feature}/
├── presentation/      # Pages, ViewModels, State classes
├── domain/           # Entities, Repository interfaces, UseCases
└── data/             # Repository implementations, DataSources, Hive models, Schemas
```

### Core Services (`lib/core/`)
- **services/**: Hive (local DB), Connectivity, Storage, Sync, Media
- **error/**: Failure classes (`ApiFailure`, `LocalDatabaseFailure`)
- **network/**: API configuration and Dio setup
- **usecase/**: Base use case interfaces
- **widgets/**: Reusable UI components

## State Management & DI Pattern

### Riverpod Providers
Uses functional Riverpod with providers defined near their implementation:
```dart
// In repositories
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final localSource = ref.read(authLocalDatasourceProvider);
  final remoteSource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(...);
});

// In presentation (NotifierProvider for mutable state)
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
```

**Key Pattern**: Providers form a dependency graph—Riverpod automatically manages instantiation and caching.

### Use Cases
Always create use cases implementing `UsecaseWithParams<ReturnType, ParamType>`:
```dart
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(authRepository: ref.read(authRepositoryProvider));
});
```

## Data Flow

### Online (Remote API)
1. UI calls ViewModel → Calls Use Case → Repository checks `NetworkInfo.isConnected`
2. Repository calls `authRemoteDataSource` (Dio) → Parses model → Converts to Entity
3. Success: Returns `Right<AuthEntity>`; Failure: Returns `Left<ApiFailure>`
4. ViewModel updates state via `AuthStatus` enum

### Offline (Local Hive)
1. If no connection: Repository uses `authLocalDataSource`
2. Hive models (e.g., `UserHiveModel`) retrieved from local boxes
3. Password verification via bcrypt, data returned as entities

**Offline-First Principle**: Always check `NetworkInfo.isConnected` before calling remote sources.

## Error Handling

### Failure Hierarchy
- Base: `Failure(String message)` - extends `Equatable`
- `ApiFailure(message, statusCode?)` - Network errors
- `LocalDatabaseFailure(message)` - Hive errors

**Pattern**: Use `Either<Failure, Entity>` from `dartz` package:
```dart
Future<Either<Failure, AuthEntity>> login(...) async {
  try {
    final result = await _authRemoteDataSource.login(...);
    return Right(result.toEntity());
  } on DioException catch (e) {
    return Left(ApiFailure(message: e.response?.data['message'] ?? 'Error'));
  } catch (e) {
    return Left(ApiFailure(message: e.toString()));
  }
}
```

## Key Dependencies & Services

- **flutter_riverpod** (3.2.0): State management & DI
- **hive** + **hive_flutter**: Offline-first local database
- **dio** + **dio_smart_retry**: HTTP client with retry logic
- **connectivity_plus**: Network status detection
- **bcrypt**: Password hashing/verification
- **dartz**: Functional programming (Either/Option)
- **flutter_secure_storage**: Secure token storage
- **shared_preferences**: User session persistence

## Initialization & Hive Setup

See [lib/main.dart](lib/main.dart#L1):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();  // Must init before app runs
  runApp(ProviderScope(child: MyApp()));
}
```

`HiveService` (in [lib/core/services/hive/hive_service.dart](lib/core/services/hive/hive_service.dart#L1)):
- Initializes path via `getApplicationDocumentsDirectory()`
- Registers adapters (e.g., `UserHiveModelAdapter()`)
- Opens boxes (tables) like `usersTable`

## Naming Conventions

- **Models**: Suffix with `Model` or `HiveModel` (e.g., `UserHiveModel`)
- **Entities**: Plain class names (e.g., `UserEntity`, `AuthEntity`)
- **Data Sources**: Suffix with `DataSource` or `RemoteDataSource`
- **View Models**: Suffix with `ViewModel`
- **Providers**: Suffix with `Provider` (e.g., `authRepositoryProvider`)
- **UseCases**: Suffix with `Usecase` (e.g., `LoginUsecase`)

## Common Workflows

### Adding a New Feature
1. Create `lib/features/{feature_name}/{presentation,domain,data}/`
2. Define entities in `domain/entities/`
3. Create repository interface in `domain/repositories/`
4. Implement repository in `data/repositories/` with local/remote data sources
5. Create use cases in `domain/usecases/` with providers
6. Build ViewModel in `presentation/view_model/` using NotifierProvider
7. Build UI pages in `presentation/pages/`

### Working with Offline Sync
- Check `await _networkInfo.isConnected` before remote calls
- Fall back to Hive queries on local data sources
- Use bcrypt for local password verification
- Store tokens via `TokenService` and user session via `UserSessionService`

### Adding Models & Hive Adapters
- Create Hive model in `data/models/{name}_hive_model.dart`
- Annotate with `@HiveType()` and fields with `@HiveField()`
- Add to `HiveService._registerAdapters()` and `_openBoxes()`
- Create schema file documenting adapter version & field mapping

## Testing
- See [test/widget_test.dart](test/widget_test.dart) for widget test pattern
- Build tests for repositories (mock data sources), use cases, and ViewModels
- Use `ProviderContainer` for testing Riverpod providers in isolation

## Build & Run
```bash
flutter pub get              # Install dependencies
flutter run -d <device_id>  # Run on device/emulator
flutter build apk            # Android release
flutter build ios            # iOS release
```

---
**Generated for Blink Flutter (sprint4 branch)**. Last updated: 2026-01-29
