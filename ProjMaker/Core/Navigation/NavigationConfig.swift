import Foundation
import SwiftUI

private struct AppNavigateKey: EnvironmentKey {
	static let defaultValue = AppRouter(
		navigate: { _, _ in },
		popTo: { _ in }
	)
}

extension EnvironmentValues {
	var router: AppRouter {
		get { self[AppNavigateKey.self] }
		set { self[AppNavigateKey.self] = newValue }
	}
}

struct AppRouter {
	private let navigateHandler: (AppRoute, PresentStyle) -> Void
	private let popToRoute: (AppRouteKey) -> Void

	init(
		navigate: @escaping (AppRoute, PresentStyle) -> Void,
		popTo: @escaping (AppRouteKey) -> Void
	) {
		self.navigateHandler = navigate
		self.popToRoute = popTo
	}

	func navigate(to route: AppRoute, _ style: PresentStyle) {
		navigateHandler(route, style)
	}

	func pop(to key: AppRouteKey) {
		popToRoute(key)
	}
}

enum PresentStyle: Hashable {
	case push
	case sheet
	case modal
	case asRoot
}
