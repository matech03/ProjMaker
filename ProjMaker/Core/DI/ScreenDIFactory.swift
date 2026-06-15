import Foundation

@MainActor
final class ScreenDIFactory {
	private let repositories: RepositoryDIFactory

	init(repositories: RepositoryDIFactory) {
		self.repositories = repositories
	}

	func makeSplashContainer() -> SplashContainer {
		SplashContainer()
	}

	func makeHomeContainer() -> HomeContainer {
		HomeContainer()
	}

	func makeWelcomeContainer() -> WelcomeContainer {
		WelcomeContainer(welcomeRepository: repositories.welcomeRepository)
	}
}
