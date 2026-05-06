import Foundation

@MainActor
final class ScreenDIFactory {
	private let useCases: UseCaseDIFactory

	init(useCases: UseCaseDIFactory) {
		self.useCases = useCases
	}

	func makeSplashContainer() -> SplashContainer {
		SplashContainer()
	}

	func makeHomeContainer() -> HomeContainer {
		HomeContainer()
	}

	func makeWelcomeContainer() -> WelcomeContainer {
		WelcomeContainer(getWelcomeGreetingUseCase: useCases.makeGetWelcomeGreetingUseCase())
	}
}
