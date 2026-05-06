import Foundation

@MainActor
final class UseCaseDIFactory {
	private let repositories: RepositoryDIFactory

	init(repositories: RepositoryDIFactory) {
		self.repositories = repositories
	}

	func makeGetWelcomeGreetingUseCase() -> GetWelcomeGreetingUseCase {
		GetWelcomeGreetingUseCase(repository: repositories.welcomeRepository)
	}
}
