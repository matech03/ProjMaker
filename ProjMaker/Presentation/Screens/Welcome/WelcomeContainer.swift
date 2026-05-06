import Foundation

struct WelcomeState {
	var greeting = ""
	var isLoading = false
}

enum WelcomeIntent {
	case onAppear
}

enum WelcomeEffect {
}

@MainActor
final class WelcomeContainer: BaseContainer<WelcomeState, WelcomeIntent, WelcomeEffect> {
	private let getWelcomeGreetingUseCase: GetWelcomeGreetingUseCase
	private var hasLoaded = false

	init(getWelcomeGreetingUseCase: GetWelcomeGreetingUseCase) {
		self.getWelcomeGreetingUseCase = getWelcomeGreetingUseCase
		super.init(initialState: WelcomeState())
	}

	override func dispatch(_ intent: WelcomeIntent) async {
		switch intent {
		case .onAppear:
			guard hasLoaded == false else { return }
			hasLoaded = true
			runTask(id: "load_welcome_greeting") { [weak self] in
				guard let self else { return }
				self.state.isLoading = true
				defer { self.state.isLoading = false }
				do {
					self.state.greeting = try await self.getWelcomeGreetingUseCase.execute()
				} catch {
					self.state.greeting = "Welcome"
					Log.error("Failed to load welcome greeting: \(error)", category: "welcome")
				}
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
