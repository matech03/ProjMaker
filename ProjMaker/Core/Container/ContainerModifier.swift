import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct BaseContainerModifier<State, Intent, Effect>: ViewModifier {
	let container: BaseContainer<State, Intent, Effect>
	let config: ContainerConfig
	@Environment(\.colorScheme) private var currentScheme

	@ViewBuilder
	func body(content: Content) -> some View {
		let tracked = content
			.onAppear {
				if config.trackAppear {
					Task { await container.dispatchSystem(.onAppear) }
				}
				if config.trackColorScheme {
					Task { await container.dispatchSystem(.colorSchemeChanged(currentScheme)) }
				}
			}
			.onDisappear {
				guard config.trackDisappear else { return }
				Task {
					await container.dispatchSystem(.onDisappear)
					container.cancelAllTasks()
				}
			}
			.onChange(of: currentScheme) { newScheme in
				guard config.trackColorScheme else { return }
				Task { await container.dispatchSystem(.colorSchemeChanged(newScheme)) }
			}

		#if canImport(UIKit)
		tracked.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
			guard config.trackOrientation else { return }
			Task { await container.dispatchSystem(.orientationChanged(UIDevice.current.orientation)) }
		}
		#else
		tracked
		#endif
	}
}

extension View {
	func attachContainer<State, Intent, Effect>(
		_ container: BaseContainer<State, Intent, Effect>,
		config: ContainerConfig = ContainerConfig()
	) -> some View {
		modifier(BaseContainerModifier(container: container, config: config))
	}
}
