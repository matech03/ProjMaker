# Navigation

## Tổng quan

Navigation được điều khiển tập trung bởi `AppNavigationHost`.

- `AppRoute`: danh sách route của app.
- `PresentStyle`: kiểu mở màn hình (`push`, `popTo`, `sheet`, `modal`).
- `router`: hàm navigate được inject qua `Environment`.
- `AppRouteFactory`: map `AppRoute` sang `View`.

Lưu ý: `push` trong `sheet` hoặc `modal` sẽ đi vào `NavigationStack` của chính container đó, không đẩy vào root stack.

## Cách navigate từ screen

### Bước 1: Lấy router từ Environment

```swift
@Environment(\.router) private var navigate
```

### Bước 2: Gọi route cần mở

```swift
navigate(.settings, .push)
navigate(.home, .popTo)
navigate(.sheetDemo, .sheet)
navigate(.modalDemo, .modal)
navigate(.home, .asRoot)
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
navigate(.profile, .push)
```

## Chọn kiểu điều hướng

- `.push`: mở màn hình trong stack hiện tại.
- `.popTo`: pop về route đã có trong stack hiện tại.
- `.sheet`: mở bottom sheet.
- `.modal`: mở full screen modal.
- `.asRoot`: đặt route làm root mới và xoá stack/sheet/modal hiện tại.

## Giới hạn hiện tại

- Không hỗ trợ mở `.modal` trực tiếp từ `.sheet`.
