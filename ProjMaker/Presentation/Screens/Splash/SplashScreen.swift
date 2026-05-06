import SwiftUI

@MainActor
struct SplashScreen: View {
	@Environment(\.router) private var navigate
	@StateObject private var container: SplashContainer

	init(container: SplashContainer) {
		_container = StateObject(wrappedValue: container)
	}

	var body: some View {
		VStack(spacing: 16) {
			Text(container.state.title)
				.font(.system(size: 24, weight: .medium))
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.safeAreaInset(edge: .bottom, content: {
			ProgressView().padding(24)
		})
		.background(Color.white)
		.attachContainer(container)
		.onReceive(container.effects) { effect in
			switch effect {
			case .navigateHome:
				navigate(.home, .asRoot)
			}
		}
	}
}
