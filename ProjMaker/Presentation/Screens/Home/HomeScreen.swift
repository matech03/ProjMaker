import SwiftUI

@MainActor
struct HomeScreen: View {
	@Environment(\.router) private var navigate
	@StateObject private var container: HomeContainer
	@State private var showsWelcomeAlert = false

	init(container: HomeContainer) {
		_container = StateObject(wrappedValue: container)
	}

	var body: some View {
		VStack(spacing: 12) {
			ForEach(container.state.actions) { item in
				actionButton(item)
			}
		}
		.padding(20)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.white)
		.attachContainer(container)
		.onReceive(container.effects) { effect in
			switch effect {
			case .showWelcomeAlert:
				showsWelcomeAlert = true
			case let .navigate(route, style):
				navigate(route, style)
			}
		}
		.alert("Welcome", isPresented: $showsWelcomeAlert) {
			Button("OK", role: .cancel) {}
		}
		.navigationTitle("Home")
		.navigationBarBackButtonHidden(true)
	}

	@ViewBuilder
	private func actionButton(_ item: HomeActionItem) -> some View {
		if #available(iOS 26.0, *) {
			Button(action: { container.send(.tapAction(item)) }) {
				Text(item.title)
					.font(.system(size: 15, weight: .semibold))
					.padding(.horizontal, 12)
					.padding(.vertical, 6)
			}.buttonStyle(.glassProminent)
		} else {
			Button(item.title) {
				container.send(.tapAction(item))
			}
			.font(.system(size: 15, weight: .semibold))
			.foregroundStyle(.white)
			.frame(width: 220)
			.padding(.vertical, 10)
			.background(Color.blue)
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
	}
}
