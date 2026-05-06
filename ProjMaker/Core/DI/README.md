# DI

## Tổng quan

DI trong project là manual factory, không dùng framework.

Mục tiêu:

- Tập trung nơi khởi tạo dependency.
- Quản lý lifecycle singleton rõ ràng.
- Tránh `Presentation` tự tạo `Service`, `Repository`, `UseCase`.
- Tránh nhầm với screen `Container`, nên dùng hậu tố `DIFactory`.

## Cấu trúc

```text
Core/DI/
├── AppDIFactory.swift
├── ServiceDIFactory.swift
├── RepositoryDIFactory.swift
├── UseCaseDIFactory.swift
└── ScreenDIFactory.swift
```

## Vai trò

### `AppDIFactory`

Root factory, nối các factory con lại với nhau.

```swift
let services = ServiceDIFactory()
let repositories = RepositoryDIFactory(services: services)
let useCases = UseCaseDIFactory(repositories: repositories)
let screens = ScreenDIFactory(useCases: useCases)
```

### `ServiceDIFactory`

Tạo và giữ service singleton.

```swift
lazy var welcomeService: WelcomeService = MockWelcomeService()
```

### `RepositoryDIFactory`

Tạo và giữ repository singleton.

```swift
lazy var welcomeRepository: WelcomeRepository = {
    DefaultWelcomeRepository(service: services.welcomeService)
}()
```

### `UseCaseDIFactory`

Tạo use case từ repository protocol.

```swift
func makeGetWelcomeGreetingUseCase() -> GetWelcomeGreetingUseCase
```

### `ScreenDIFactory`

Tạo screen container cho `Presentation`.

```swift
func makeWelcomeContainer() -> WelcomeContainer
```

## Cách dùng

`ProjMakerApp` tạo `AppDIFactory`, sau đó truyền vào navigation host.

```swift
private let diFactory = AppDIFactory()

AppNavigationHost(diFactory: diFactory)
```

`AppRouteFactory` chỉ lấy container từ `ScreenDIFactory`.

```swift
WelcomeScreen(
    title: "Welcome",
    container: diFactory.screens.makeWelcomeContainer()
)
```

## Quy tắc

- Service/API/cache/db/keychain: tạo trong `ServiceDIFactory`.
- Repository implementation: tạo trong `RepositoryDIFactory`.
- UseCase: tạo trong `UseCaseDIFactory`.
- Screen Container: tạo trong `ScreenDIFactory`.
- `Presentation` không tự tạo `Service` hoặc `Repository`.
- Không dùng global singleton như `AppDIFactory.shared`.
