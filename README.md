# Liftlog

A native iOS workout tracking app built with Swift and SwiftUI. Designed to demonstrate clean architecture, modern Swift concurrency, and thoughtful UI — without any third-party dependencies.

---

## Screenshots

> _Coming soon_

---

## Features

- **Exercise Library** — create and manage your personal exercise database with support for weighted and timed exercises
- **Workout Tracking** — log workouts, add exercises from your library, and record sets with reps/weight or duration
- **Set History** — view previous sets for any exercise across all past workouts, right where you need them
- **Tags** — organize workouts with custom tags and filter your history by tag
- **Liquid Glass UI** — adaptive interface that takes advantage of iOS 26 Liquid Glass while gracefully falling back to a native iOS 18 design

---

## Architecture

Liftlog is built around a strict separation of concerns across three layers.

### Persistence Layer
CoreData is used for local persistence. `NSManagedObject` subclasses are never exposed to the UI — all CoreData entities are mapped to plain Swift structs at the repository boundary.

### Domain Layer
All business logic operates on value types:

```swift
struct WorkoutModel: Identifiable, Equatable, Hashable, Sendable { ... }
struct ExerciseSetModel: Identifiable, Equatable, Hashable, Sendable { ... }

enum SetType {
    case weighted(reps: Int, weight: Double)
    case timed(duration: TimeInterval)
}
```

`SetType` as an enum with associated values means the UI never deals with optional fields — a set is either weighted or timed, and the type system enforces that.

### Repository Layer
Each repository is defined by a protocol and has a CoreData implementation and a mock implementation for tests and previews:

```swift
protocol WorkoutRepositoryProtocol: AnyObject {
    func fetchAll() async throws -> [WorkoutModel]
    func create(_ model: WorkoutModel) async throws -> WorkoutModel
    func addExercise(_ model: WorkoutExerciseModel, to workoutID: UUID) async throws
    func addSet(_ model: ExerciseSetModel, to workoutExerciseID: UUID) async throws
    // ...
}
```

### Dependency Injection
Dependencies are composed at app launch through `AppDependencies` and surfaced to the view hierarchy via a `ViewModelFactory` injected into SwiftUI's environment:

```swift
@Observable
final class ViewModelFactory {
    func makeWorkoutListViewModel() -> WorkoutListViewModel { ... }
    func makeWorkoutDetailViewModel(_ workout: WorkoutModel) -> WorkoutDetailViewModel { ... }
    func makeExerciseSetViewModel(workoutExercise: WorkoutExerciseModel) -> ExerciseSetViewModel { ... }
}
```

Views receive a fully constructed ViewModel through `init` — they never instantiate dependencies themselves.

### Navigation
A centralized `NavigationManager` holds a `NavigationPath` and all routing is handled through a typed `Route` enum. A single `navigationDestination` in `RootView` owns the mapping from route to view:

```swift
enum Route: Hashable {
    case workoutDetail(WorkoutModel)
    case exerciseSet(WorkoutExerciseModel)
    case exerciseLibrary
}
```

---

## Tech Stack

| | |
|---|---|
| **Language** | Swift 6 |
| **UI** | SwiftUI |
| **Persistence** | CoreData |
| **Concurrency** | Swift Concurrency (`async/await`, `Task`, `actor`) |
| **Testing** | Swift Testing (`@Suite`, `@Test`, `#expect`) |
| **Deployment Target** | iOS 18+ |
| **Dependencies** | None |

---

## Project Structure

```
Liftlog/
├── App/
│   ├── LiftlogApp.swift
│   ├── RootView.swift
│   └── AppDependencies.swift
├── Core/
│   ├── Domain/              # Pure Swift models and enums
│   ├── Persistence/         # CoreData stack + NSManagedObject mappings
│   └── Repositories/        # Protocols + CoreData implementations
├── Features/
│   ├── Workout/             # Workout list, detail, create/edit
│   ├── Library/             # Exercise library
│   └── Sets/                # Set logging and history
└── Shared/
    ├── Components/          # Reusable UI components
    └── Mocks/               # Mock repositories for tests and previews
```

---

## Testing

Tests are written with Swift Testing and cover three layers:

**ViewModel tests** use mock repositories to test business logic in isolation:

```swift
@Suite("WorkoutDetailViewModel")
@MainActor
struct WorkoutDetailViewModelTests {

    @Test("Cannot add the same exercise twice")
    func preventsDuplicateExercise() async {
        await viewModel.addExercise(ExerciseModel.mock)
        await viewModel.addExercise(ExerciseModel.mock)
        #expect(viewModel.workout.exercises.count == 1)
        #expect(viewModel.error != nil)
    }
}
```

**Repository tests** use an in-memory CoreData stack to test persistence logic without side effects:

```swift
init() {
    let context = PersistenceController(inMemory: true).container.viewContext
    repository = CoreDataExerciseRepository(context: context)
}
```

**Mapping tests** verify that CoreData entities correctly map to domain models, including the `SetType` discrimination logic.

Mock repositories expose `.mock`, `.preview`, and `.unimplemented` static variants — a pattern inspired by Point-Free's approach to dependency management:

```swift
extension MockExerciseRepository {
    static var mock: MockExerciseRepository { MockExerciseRepository() }
    static var preview: MockExerciseRepository { ... }  // pre-populated
    static var unimplemented: MockExerciseRepository { ... }  // always throws
}
```

---

## iOS Version Support

The app targets iOS 18+ with progressive enhancement for iOS 26:

```swift
extension Button {
    @ViewBuilder
    func adaptiveGlassProminentButton() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
                .glassEffect(.regular.interactive())
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}
```

All `#available` checks are isolated to dedicated extensions and components — feature Views contain no version branching.

---

## Roadmap

- [ ] CloudKit sync across devices
- [ ] Progress charts with Swift Charts
- [ ] Rest timer
- [ ] Workout templates
- [ ] Localization
- [ ] App Store release

---

## Requirements

- Xcode 16+
- iOS 18.0+
- No external dependencies — clone and run

---

## Author

Pavel Martynenkov — iOS Developer  
[LinkedIn](https://www.linkedin.com/in/pavel-m-392374181/) · [GitHub](https://github.com/Pashokresh)
