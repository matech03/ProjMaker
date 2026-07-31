# Project Guide

Guide tổng cho project. Khi bắt đầu code gen/edit/refactor/fix/review, đọc file này trước. Nếu task chạm vào Navigation, Container hoặc DI thì đọc thêm README chuyên sâu tương ứng.

## Tài liệu liên quan

- Navigation Guide (`<ProjectName>/Core/Navigation/README.md`): route, router, `push/sheet/modal`.
- Container Guide (`<ProjectName>/Core/Container/README.md`): `State`, `Intent`, `Effect`, lifecycle, async task.
- DI Guide (`<ProjectName>/Core/DI/README.md`): `DIFactory` và manual dependency injection.

## Cấu trúc project

Project dùng layer-first architecture giản lược, không có tầng Domain riêng.

```text
<ProjectName>/
├── Core/
│   ├── App/          # App entry
│   ├── Container/    # BaseContainer + lifecycle modifier
│   ├── DI/           # Manual DIFactory
│   └── Navigation/   # AppRoute + AppNavigationHost
├── Utils/            # Shared helpers
│   └── Extensions/   # Swift extensions
├── Presentation/     # Screens + shared UI components
├── Data/             # Models + repository protocols/implementations + services
└── Resources/        # Image.xcassets + Color.xcassets
```

## Base project version

Thông tin base project nằm trong `.base-project-info.json` ở root project. Sau khi chạy `scripts/make-project.sh`, project mới giữ file này để xem base version, `changeLogs`, và `generatedAt`.

## Dependency flow

```text
Presentation -> Repository protocol -> Repository implementation -> Service
```

Rule chính:

- `View` chỉ render UI, đọc `container.state`, gửi `Intent`.
- `Container` xử lý state/intent/effect, gọi `Repository` protocol, không gọi `Service` trực tiếp.
- Repository protocol nằm trong `Data/Repositories` cùng repository implementation.
- Model dùng cho business/UI state nằm trong `Data/Models`.
- `Service` trả về Model; không tạo DTO layer riêng.
- Dependency được tạo trong `Core/DI`, không tạo sâu trong View.

## Layer responsibilities

### Presentation

Đặt trong:

```text
Presentation/
├── Screens/
│   └── <ScreenName>/
│       ├── <ScreenName>Screen.swift
│       └── <ScreenName>Container.swift
└── Views/              # shared UI components/custom views
```

- `Screen`: SwiftUI layout, action binding, alert/sheet UI state nếu cần.
- `Container`: `State`, `Intent`, `Effect`, async task, business-facing UI logic.
- `Views`: UI components/custom views dùng chung giữa nhiều screen.
- Nếu có side effect one-shot như navigate/alert/toast/dismiss, dùng `Effect`.

### Data

Đặt trong:

```text
Data/Models/
Data/Services/
Data/Repositories/
```

- `Models`: model dùng cho business/UI state.
- `Services`: API/local/mock/cache/keychain.
- `Repositories`: repository protocol và implementation; implementation gọi Service.

### Core, Utils, Extensions

- `Core/App`: app root.
- `Core/Container`: base State-Intent-Effect infrastructure.
- `Core/Navigation`: centralized navigation.
- `Core/DI`: manual DI bằng `DIFactory`.
- `Utils`: helper dùng chung.
- `Utils/Extensions`: extensions dùng chung.

## Naming convention

- Screen: `<Name>Screen`
- Container: `<Name>Container`
- State: `<Name>State`
- Intent: `<Name>Intent`
- Effect: `<Name>Effect`
- Model: `<Entity>`
- Repository protocol: `<Entity>Repository`
- Repository implementation: `Default<Entity>Repository`
- Service: `<Entity>Service` hoặc `<Purpose>Service`
- DI factory: `<Layer>DIFactory`

## Navigation

Navigation đi qua `AppRoute`, `AppRouteFactory`, và `router`.

```swift
@Environment(\.router) private var router

router.navigate(to: .welcome(showCloseButton: false), .push)
```

Khi thêm màn hình mới:

1. Thêm case vào `AppRoute`.
2. Map route trong `AppRouteFactory`.
3. Từ screen gọi `router.navigate(to: route, style)`.

Style:

- `.push`: push trong stack hiện tại.
- `router.pop(to: .home)`: pop về route có tên case trùng key trong stack hiện tại, không cần truyền lại associated values.
- `.sheet`: bottom sheet.
- `.modal`: full screen modal.
- `.asRoot`: đặt route làm root mới và xoá stack/sheet/modal hiện tại.

## DI

Manual DI nằm trong `Core/DI`.

```text
AppDIFactory
├── ServiceDIFactory
├── RepositoryDIFactory
└── ScreenDIFactory
```

Quy tắc:

- Service singleton tạo trong `ServiceDIFactory`.
- Repository singleton tạo trong `RepositoryDIFactory`.
- Screen container tạo trong `ScreenDIFactory`.
- Không dùng `AppDIFactory.shared`.
- Không dùng hậu tố `DIContainer` để tránh nhầm với screen `Container`.

## Workflow tạo màn hình mới

1. Tạo `Presentation/Screens/<ScreenName>/`.
2. Tạo `<ScreenName>Screen.swift` và `<ScreenName>Container.swift`.
3. Khai báo `State`, `Intent`, `Effect` trong container.
4. Nếu có data/business flow, bổ sung `Data/Models`, `Data/Services`, và `Data/Repositories`.
5. Nếu có dependency mới, bổ sung factory tương ứng trong `Core/DI`.
6. Nếu cần navigation, thêm `AppRoute` và mapping trong `AppRouteFactory`.
7. Build và verify UI nếu có thay đổi giao diện.

## Workflow thêm chức năng có data

1. Thêm/cập nhật Model trong `Data/Models` nếu cần.
2. Thêm Service protocol/implementation trong `Data/Services`.
3. Thêm Repository protocol và implementation trong `Data/Repositories`.
4. Inject Repository protocol vào Container qua initializer.
5. Đăng ký dependency trong `Core/DI`.
6. UI chỉ đọc state và gửi intent.

## Logging

Không dùng `print(...)` cho debug/logging.

Dùng `Log` trong `Utils/Log.swift`:

```swift
Log.debug("message")
Log.info("message")
Log.error("message", category: "welcome")
```

## Checklist trước khi xong

- Đúng layer: `Presentation`, `Data`, `Core`.
- View không chứa business logic phức tạp.
- Container gọi Repository protocol, không gọi Service trực tiếp.
- Repository implementation gọi Service khi cần data.
- Model nằm trong `Data/Models`; không dùng DTO layer riêng.
- Navigation đi qua `AppRoute`/`AppRouteFactory`/`router`.
- Dependency mới được đăng ký trong `Core/DI`.
- Không có `print(...)`.
- Nếu đổi UI, đã chạy app và verify khi có thể.
