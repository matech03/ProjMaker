# Navigation

## Tổng quan

Navigation được điều khiển tập trung bởi `AppNavigationHost`.

- `AppRoute`: danh sách route của app.
- `PresentStyle`: kiểu mở màn hình (`push`, `popTo`, `sheet`, `modal`).
- `router`: `AppRouter` được inject qua `Environment`, gọi rõ bằng `navigate(to:_:)` hoặc `pop(to:)`.
- `AppRouteFactory`: map `AppRoute` sang `View`.

Lưu ý: `push` trong `sheet` hoặc `modal` sẽ đi vào `NavigationStack` của chính container đó, không đẩy vào root stack.

## Cách navigate từ screen

### Bước 1: Lấy router từ Environment

```swift
@Environment(\.router) private var router
```

### Bước 2: Gọi route cần mở

```swift
router.navigate(to: .settings, .push)
router.pop(to: .home)
router.navigate(to: .sheetDemo, .sheet)
router.navigate(to: .modalDemo, .modal)
router.navigate(to: .home, .asRoot)
```

## Cách thêm route mới

### Bước 1: Thêm case vào `AppRoute`

```swift
enum AppRoute: Hashable, Identifiable {
    case profile
}
```

### Bước 2: Map route sang màn hình trong `AppRouteFactory`

```swift
case .profile:
    ProfileScreen()
```

### Bước 3: Navigate tới route đó

```swift
router.navigate(to: .profile, .push)
```

## Chọn kiểu điều hướng

- `.push`: mở màn hình trong stack hiện tại.
- `router.pop(to: .home)`: pop về route có tên case trùng key trong stack hiện tại, không cần truyền lại associated values.
- `.sheet`: mở bottom sheet.
- `.modal`: mở full screen modal.
- `.asRoot`: đặt route làm root mới và xoá stack/sheet/modal hiện tại.

## Giới hạn hiện tại

- Không hỗ trợ mở `.modal` trực tiếp từ `.sheet`.
