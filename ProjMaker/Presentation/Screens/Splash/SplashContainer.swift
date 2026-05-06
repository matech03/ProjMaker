import Foundation

struct SplashState {
	let title = AppInfo.appName
}

enum SplashIntent {
	case onAppear
}

enum SplashEffect {
	case navigateHome
}

@MainActor
final class SplashContainer: BaseContainer<SplashState, SplashIntent, SplashEffect> {
	private var hasNavigated = false

	init() {
		super.init(initialState: SplashState())
	}

	override func dispatch(_ intent: SplashIntent) async {
		switch intent {
		case .onAppear:
			guard hasNavigated == false else { return }
			hasNavigated = true
			runTask(id: "splash_navigate_home") { [weak self] in
				guard let self else { return }
				try? await Task.sleep(nanoseconds: 700_000_000)
				self.sendEffect(.navigateHome)
			}
		}
	}

	override func dispatchSystem(_ intent: SystemIntent) async {
		switch intent {
		case .onAppear:
			await dispatch(.onAppear)
		default:
			break
		}
	}
}
