# CLAUDE.md — Liftlog

## Project Overview

Liftlog is a native iOS workout tracking app built with Swift 6, SwiftUI, and CoreData. No third-party dependencies. Deployment target: iOS 18+, with progressive enhancement for iOS 26 Liquid Glass.

---

## Architecture

### Layers (strict separation — never skip)

```
CoreData (NSManagedObject)
    ↓  mapping via toDomain()
Domain Models (Swift structs)
    ↓
Repositories (protocol + CoreData implementation)
    ↓
ViewModels (@Observable final class)
    ↓
Views (SwiftUI)
```

- **Views never touch NSManagedObject directly**
- **ViewModels never import CoreData**
- **Repositories return Domain Models only**

### Dependency Injection

Dependencies are composed in `AppDependencies` and delivered via `ViewModelFactory` injected into SwiftUI environment:

```swift
@Environment(ViewModelFactory.self) private var factory
```

ViewModels are created in `ViewModelFactory` and passed to Views through `init`. Views never instantiate repositories themselves.

### Navigation

Centralized `NavigationManager` with `NavigationPath`. Single `navigationDestination` in `RootView`. Typed `Route` enum in `Core/Navigation/Route.swift`.

---

## Project Structure

```
Liftlog/
├── App/
│   ├── LiftlogApp.swift
│   ├── RootView.swift
│   ├── ViewModelFactory.swift
│   └── AppDependencies.swift
├── Core/
│   ├── Navigation/
│   │   ├── NavigationManager.swift
│   │   └── Route.swift
│   ├── Domain/
│   │   ├── ExerciseModel.swift        # includes ExerciseType, MuscleGroup as nested enums
│   │   ├── ExerciseSetModel.swift
│   │   ├── WorkoutModel.swift
│   │   ├── WorkoutExerciseModel.swift
│   │   ├── TagModel.swift
│   │   ├── ExerciseHistorySectionModel.swift
│   │   ├── ExerciseProgressEntry.swift
│   │   ├── MuscleGroupSection.swift
│   │   ├── Errors.swift
│   │   └── Utils/
│   │       └── OrderedSet.swift
│   ├── Persistence/
│   │   ├── Persistence.swift
│   │   ├── Request.swift
│   │   └── Mapping/
│   │       ├── Exercise+Mapping.swift
│   │       ├── ExerciseSet+Mapping.swift
│   │       ├── Workout+Mapping.swift
│   │       ├── WorkoutExercise+Mapping.swift
│   │       └── Tag+Mapping.swift
│   └── Repositories/
│       ├── ExerciseRepository/
│       │   ├── ExerciseRepositoryProtocol.swift
│       │   └── CoreDataExerciseRepository.swift
│       ├── WorkoutRepository/
│       │   ├── WorkoutRepositoryProtocol.swift
│       │   └── CoreDataWorkoutRepository.swift
│       └── TagRepository/
│           ├── TagRepositoryProtocol.swift
│           └── CoreDataTagRepository.swift
├── Features/
│   ├── Workout/
│   │   ├── WorkoutList/
│   │   │   ├── WorkoutListView.swift
│   │   │   ├── WorkoutListViewModel.swift
│   │   │   ├── WorkoutRowView.swift
│   │   │   └── TagSortButton.swift
│   │   ├── AddEditWorkout/
│   │   │   ├── AddEditWorkoutView.swift
│   │   │   └── AddEditWorkoutViewModel.swift
│   │   └── Set/
│   │       ├── ExerciseSetListView.swift
│   │       ├── ExerciseSetViewModel.swift
│   │       ├── AddEditSetView.swift
│   │       ├── SetRowView.swift
│   │       ├── WeightInputView.swift
│   │       └── DurationInputView.swift
│   ├── Library/
│   │   ├── ExerciseLibraryView.swift
│   │   ├── ExerciseLibraryViewModel.swift
│   │   ├── AddEditExerciseView.swift
│   │   ├── ExerciseRowView.swift
│   │   └── ExercisePicker/
│   │       ├── ExercisePickerView.swift
│   │       ├── ExercisePickerViewModel.swift
│   │       ├── ExercisePickerRowView.swift
│   │       └── SelectedOrderIndicator.swift
│   └── Progress/
│       └── ExerciseProgressViewModel.swift
└── Shared/
    ├── Components/
    ├── Localization/
    │   └── AppLocalization.swift
    └── Mocks/

LiftlogTests/
├── ViewModels/
├── Repositories/
├── Mapping/
└── Common/
```

---

## Localization — AppLocalization

**All user-facing strings must go through `AppLocalization`** — never use raw `String(localized:)` or string literals directly in Views or ViewModels.

`AppLocalization` is an enum in `Shared/Localization/AppLocalization.swift` with static properties grouped by feature using `// MARK:`.

### Rules

- Never write `String(localized: "Some text")` in a View or ViewModel
- Never write raw string literals in UI code: `Text("Add Exercise")`
- Always use `AppLocalization.someKey` instead
- When adding a new string: add it to `AppLocalization` first, then use it
- Group under the relevant `// MARK:` section — add a new section if needed
- For parameterized strings use static functions:

```swift
// CORRECT
Text(AppLocalization.addExercise)
Button(AppLocalization.save) { ... }

// WRONG
Text(String(localized: "Add Exercise"))
Text("Add Exercise")
Button("Save") { ... }
```

### When adding a new feature

1. Add all new strings to `AppLocalization` under a new or existing `// MARK:` section
2. Use only `AppLocalization.*` in Views and ViewModels
3. Never leave raw string literals in UI code

---

## Testing Requirements

**When adding or modifying any feature, always check if tests need to be added or updated. Proactively suggest missing tests.**

### Coverage expectations

| Layer | Test type | Location |
|---|---|---|
| ViewModel business logic | Unit test with Mock repository | `LiftlogTests/ViewModels/` |
| Repository CRUD | Integration test with inMemory CoreData | `LiftlogTests/Repositories/` |
| Domain model mapping | Unit test | `LiftlogTests/Mapping/` |
| Utilities | Unit test | `LiftlogTests/Common/` |

### After implementing a feature, always

1. Check if existing tests still pass — mention if they need updating
2. Add tests for new ViewModel methods containing business logic
3. Add tests for new repository methods
4. Add tests for new or changed `toDomain()` mapping logic
5. Suggest test cases even if not explicitly asked by the user

### Test rules

- Use Swift Testing — `@Suite`, `@Test`, `#expect` — never XCTest
- Each test gets a fresh in-memory CoreData context in `init()`
- Never use shared static `PersistenceController.inMemory` in tests — state bleeds between tests
- Use `.mock` for empty state, `.preview` for pre-populated, `.unimplemented` for error cases

```swift
// CORRECT — fresh context per test
init() {
    let context = PersistenceController(inMemory: true).container.viewContext
    repository = CoreDataExerciseRepository(context: context)
}

// WRONG — shared state bleeds between tests
init() {
    repository = CoreDataExerciseRepository(
        context: PersistenceController.inMemory.container.viewContext
    )
}
```

---

## Key Domain Models

```swift
// SetType — never use optionals for reps/weight/duration
enum SetType {
    case weighted(reps: Int, weight: Double)
    case timed(duration: TimeInterval)
}

// ExerciseType and MuscleGroup are nested inside ExerciseModel
// MuscleGroup is optional — user may not specify it
// isWarmup: Bool on ExerciseSetModel — warmup sets are excluded from progress calculations
```

---

## Coding Rules

### Swift & SwiftUI

- Swift 6 strict concurrency — all domain models must conform to `Sendable`
- Use `@Observable` — never `ObservableObject` or `@Published`
- Use `async/await` — never completion handlers or Combine
- Use `context.perform { }` for all CoreData operations
- ViewModels must be `@MainActor final class`
- Use `private(set)` for ViewModel properties exposed to View
- Never use `!` force unwrap — use `guard`, `if let`, or `?? default`
- Use `AppLocalization.*` for all user-facing strings

### SwiftLint

Follow all rules in `.swiftlint.yml`. Key enforced rules:
- `force_unwrapping` — error, never use `!`
- `implicitly_unwrapped_optional` — error
- `empty_count` — always use `.isEmpty` instead of `== 0` or `== []`
- Maximum line length: 120 characters
- Trailing newline required

Before suggesting any code, verify it would not trigger SwiftLint warnings or errors. Fix violations before presenting code.

### iOS Version Support

All `#available` checks belong in extensions and components — never inside feature Views:

```swift
// CORRECT — isolated in extension
extension Button {
    @ViewBuilder
    func adaptiveGlassStyle() -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}

// WRONG — #available inside feature View body
var body: some View {
    if #available(iOS 26, *) {
        Button { }.buttonStyle(.glassProminent)
    } else {
        Button { }.buttonStyle(.borderedProminent)
    }
}
```

### CoreData

- Always use `context.perform { }` for async operations
- Always handle optional CoreData properties with `?? default`
- Cascade delete: parent → child only, never child → parent
- Schema changes require a new model version (lightweight migration)
- Never expose `NSManagedObject` outside the persistence layer

---

## Patterns to Follow

### ViewModel

```swift
@Observable
@MainActor
final class ExampleViewModel {
    private(set) var items: [ItemModel] = []
    private(set) var error: Error?

    private let repository: ItemRepositoryProtocol

    init(repository: ItemRepositoryProtocol) {
        self.repository = repository
    }

    func loadItems() async {
        do {
            items = try await repository.fetchAll()
        } catch {
            self.error = error
        }
    }

    func nullifyError() { error = nil }
}
```

### Repository protocol

```swift
protocol ItemRepositoryProtocol: AnyObject {
    func fetchAll() async throws -> [ItemModel]
    func create(_ model: ItemModel) async throws -> ItemModel
    func update(_ model: ItemModel) async throws
    func delete(_ id: UUID) async throws
}
```

### View

```swift
struct ExampleView: View {
    @State private var viewModel: ExampleViewModel

    init(viewModel: ExampleViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    var body: some View { ... }
}
```

### Mock pattern

```swift
extension MockItemRepository {
    static var mock: MockItemRepository { MockItemRepository() }
    static var preview: MockItemRepository { /* pre-populated */ }
    static var unimplemented: MockItemRepository { /* always throws */ }
}
```

---

## What NOT to Do

- Never use `ObservableObject` or `@Published`
- Never use Combine
- Never expose `NSManagedObject` to ViewModels or Views
- Never create ViewModels inside Views — use `ViewModelFactory`
- Never use `@Environment(\.managedObjectContext)` in Views
- Never skip `toDomain()` mapping
- Never add third-party dependencies without discussion
- Never add `@MainActor` to test Suites unless testing MainActor-isolated code
- Never use `PersistenceController.shared` in tests
- Never write `== 0` or `== []` — use `.isEmpty`
- Never use raw string literals in UI — always `AppLocalization.*`
- Never write `String(localized:)` directly in Views or ViewModels
