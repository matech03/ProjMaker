import SwiftUI

@MainActor
struct WelcomeScreen: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.router) private var navigate
	@StateObject private var container: WelcomeContainer

	let title: String
	var showsCloseButton: Bool = false

	init(
		title: String,
		showsCloseButton: Bool = false,
		container: WelcomeContainer
	) {
		self.title = title
		self.showsCloseButton = showsCloseButton
		_container = StateObject(wrappedValue: container)
	}

	var body: some View {
		VStack(spacing: 12) {
			Spacer()
			Text(title)
				.font(.system(size: 24, weight: .bold))
			if container.state.isLoading {
				ProgressView()
			}
			Text(container.state.greeting)
				.font(.system(size: 16, weight: .regular))
				.foregroundStyle(.secondary)
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.white)
		.attachContainer(container)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				if showsCloseButton {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
	}
}
