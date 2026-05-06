# Container

## Tổng quan

`Core/Container` cung cấp base cho pattern State - Intent - Effect trong `Presentation`.

```text
Presentation/Screens/<ScreenName>/
├── <ScreenName>Screen.swift
└── <ScreenName>Container.swift
```

- `State`: dữ liệu UI render lâu dài.
- `Intent`: action từ user hoặc business action.
- `Effect`: one-shot event như navigate, alert, toast, dismiss.
- `BaseContainer`: giữ state, chạy task, gửi effect.
- `attachContainer`: gắn lifecycle SwiftUI vào container.

## Quy tắc

- Container chạy trên `@MainActor`.
- View chỉ đọc `container.state` và gửi `Intent`.
- Business/data flow đi qua `UseCase`.
- Container nhận UseCase qua initializer.
- Container không tự tạo Service/Repository.
- Dependency được tạo trong `Core/DI`.
- Async work nên chạy bằng `runTask(id:)` để dễ cancel/restart.

## Tạo Container

```swift
struct ProfileState {
    var isLoading = false
}

enum ProfileIntent {
    case tapSave
}

enum ProfileEffect {
    case saved
}

@MainActor
final class ProfileContainer: BaseContainer<ProfileState, ProfileIntent, ProfileEffect> {
    private let saveProfileUseCase: SaveProfileUseCase

    init(saveProfileUseCase: SaveProfileUseCase) {
        self.saveProfileUseCase = saveProfileUseCase
        super.init(initialState: ProfileState())
    }

    override func dispatch(_ intent: ProfileIntent) async {
        switch intent {
        case .tapSave:
            sendEffect(.saved)
        }
    }

    override func dispatchSystem(_ intent: SystemIntent) async {
        switch intent {
        case .onAppear:
            await loadIfNeeded()
        default:
            break
        }
    }

    private func loadIfNeeded() async {
        // load initial data
    }
}
```

## Dùng trong View

```swift
@StateObject private var container: ProfileContainer

var body: some View {
    Button("Save") {
        container.send(.tapSave)
    }
    .attachContainer(container)
    .onReceive(container.effects) { effect in
        switch effect {
        case .saved:
            break
        }
    }
}
```

## Lifecycle

`attachContainer` tự gửi system event nếu config bật.

Mặc định track:

- `onAppear`
- `onDisappear`

Override khi cần. Lifecycle đi qua `SystemIntent`, không cần thêm `.onAppear` vào user `Intent`.

```swift
override func dispatchSystem(_ intent: SystemIntent) async {
    switch intent {
    case .onAppear:
        await loadIfNeeded()
    default:
        break
    }
}
```

Bật thêm event khác:

```swift
.attachContainer(
    container,
    config: ContainerConfig(
        trackColorScheme: true,
        trackOrientation: true
    )
)
```

## Async task

Dùng `runTask(id:)` cho async task trong Container.

```swift
runTask(id: "load_profile") { [weak self] in
    guard let self else { return }
    self.state.isLoading = true
    defer { self.state.isLoading = false }
    // await useCase.execute()
}
```

Khi View disappear, `attachContainer` sẽ gọi `cancelAllTasks()` nếu `trackDisappear = true`.

## Checklist

1. Tạo `State`, user/business `Intent`, và one-shot `Effect`.
2. Kế thừa `BaseContainer<State, Intent, Effect>`.
3. Inject UseCase qua initializer nếu có dependency.
4. Xử lý user/business action trong `dispatch(_:)`.
5. Xử lý lifecycle trong `dispatchSystem(_:)` khi cần.
6. Gửi one-shot event bằng `sendEffect(_:)`.
7. Từ View gửi user intent bằng `container.send(...)`.
8. Gắn `.attachContainer(container)` trong View.
9. Lắng nghe `container.effects` bằng `.onReceive`.
