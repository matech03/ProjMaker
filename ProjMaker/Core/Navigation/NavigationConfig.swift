import Foundation
import SwiftUI

private struct AppNavigateKey: EnvironmentKey {
	static let defaultValue: (AppRoute, PresentStyle) -> Void = { _, _ in }
}

extension EnvironmentValues {
	var router: (AppRoute, PresentStyle) -> Void {
		get { self[AppNavigateKey.self] }
		set { self[AppNavigateKey.self] = newValue }
	}
}

enum PresentStyle: Hashable {
	case push
	case sheet
	case modal
	case asRoot
}
