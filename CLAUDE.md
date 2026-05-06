# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Required project reading

Before code generation, editing, refactoring, bug fixing, or reviewing, read `README.md` and follow its architecture, coding conventions, workflows, and checklist.

Also read these when relevant:

- `ProjMaker/Core/Navigation/README.md` for route, router, `push/sheet/modal`, and navigation behavior.
- `ProjMaker/Core/Container/README.md` for `State`, `Intent`, `Effect`, `BaseContainer`, lifecycle, async tasks, and effects.

## Common commands

This is an iOS app using an Xcode workspace with CocoaPods.

```bash
pod install
```

Build the app from CLI:

```bash
xcodebuild -workspace ProjMaker.xcworkspace -scheme ProjMaker -configuration Debug -destination 'generic/platform=iOS Simulator' build
```

Open the project in Xcode:

```bash
open ProjMaker.xcworkspace
```

There is currently no test target in the workspace. When a test target is added, use Xcode's standard test command pattern:

```bash
xcodebuild test -workspace ProjMaker.xcworkspace -scheme ProjMaker -destination 'platform=iOS Simulator,name=<Simulator Name>'
xcodebuild test -workspace ProjMaker.xcworkspace -scheme ProjMaker -destination 'platform=iOS Simulator,name=<Simulator Name>' -only-testing:<TestTarget>/<TestClass>/<testMethod>
```

## Architecture summary

The project uses a layer-first Clean Architecture style documented in `README.md`.

Top-level structure:

- `ProjMaker/Core/App`: app entry point and root app wiring.
- `ProjMaker/Core`: shared infrastructure such as Navigation, Container, and DI. `Core/DI` is split by Service, Repository, UseCase, and Screen containers.
- `ProjMaker/Utils`: shared helpers.
- `ProjMaker/Utils/Extensions`: Swift extensions.
- `ProjMaker/Presentation/Screens`: feature screens and their containers.
- `ProjMaker/Presentation/Views`: shared UI components and custom views.
- `ProjMaker/Domain`: domain models, repository protocols, and use cases.
- `ProjMaker/Data`: DTOs, services, and repository implementations.

Core flow for UI features:

- SwiftUI `View` renders from `container.state`.
- User actions become `Intent`.
- `Container` handles state transitions, async tasks, and one-shot `Effect` values.
- Navigation goes through `AppRoute`, `AppRouteFactory`, and `@Environment(\.router)`.

For any screen or function with API, local storage, fetch/save/update/delete, or business rules, implement the full data flow from `README.md`:

```text
Presentation -> UseCase -> Repository protocol -> Repository implementation -> Service
```

Rules:

- `View` must not call Service, Repository, API, or local storage directly.
- `Container` must not call Service directly; it calls UseCase.
- UseCase depends on Repository protocol from Domain.
- Repository implementation in Data calls Service and maps DTO to Domain Model.
- DTO stays in Data and must not be rendered directly by Presentation/UI.

## Navigation rules

When adding a screen:

1. Add a case to `AppRoute`.
2. Map the route in `AppRouteFactory`.
3. Navigate from screens using `@Environment(\.router)`.

Use `PresentStyle` consistently:

- `.push`: stack navigation in the current context.
- `.sheet`: bottom sheet presentation.
- `.modal`: full-screen presentation.
- `.asRoot`: replace the root route and clear the current stack, sheet, and modal.

Current limitation: opening `.modal` directly from `.sheet` is not supported.

## Container rules

Feature screens should use the Container pattern:

- Define `FeatureState`, `FeatureIntent`, `FeatureEffect`.
- Create `FeatureContainer: BaseContainer<FeatureState, FeatureIntent, FeatureEffect>`.
- Override `dispatch(_:)` for user intents.
- Use `runTask(id:)` for async work that should be cancellable/restartable.
- Use `sendEffect(_:)` for one-shot events such as navigation, alert, toast, or dismiss.
- Attach lifecycle with `.attachContainer(container)`.

## Logging rules

Do not use `print(...)` for generated debug/logging code.

Use `Log` from `ProjMaker/Utils/Log.swift`:

```swift
Log.debug("Loaded profile")
Log.info("Navigate to settings")
Log.error("Failed to load profile: \(error)")
Log.debug("Request started", category: "profile")
```

## Code generation constraints

- Prefer the smallest change that satisfies the task.
- Do not introduce abstractions beyond the current requirement.
- Do not add comments unless the reason is non-obvious.
- If a UI change is made, run and verify the app behavior when possible.
