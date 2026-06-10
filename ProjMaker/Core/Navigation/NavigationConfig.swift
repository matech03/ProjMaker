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
	private let navigate: (AppRoute, PresentStyle) -> Void
	private let popToRoute: (AppRouteKey) -> Void

	init(
		navigate: @escaping (AppRoute, PresentStyle) -> Void,
		popTo: @escaping (AppRouteKey) -> Void
	) {
		self.navigate = navigate
		self.popToRoute = popTo
	}

	func callAsFunction(_ route: AppRoute, _ style: PresentStyle) {
		navigate(route, style)
	}

	func popTo(_ key: AppRouteKey) {
		popToRoute(key)
	}
}

enum PresentStyle: Hashable {
	case push
	case sheet
	case modal
	case asRoot
}
