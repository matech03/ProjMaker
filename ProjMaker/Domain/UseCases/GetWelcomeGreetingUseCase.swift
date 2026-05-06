import Foundation

struct GetWelcomeGreetingUseCase {
	private let repository: WelcomeRepository

	init(repository: WelcomeRepository) {
		self.repository = repository
	}

	func execute() async throws -> String {
		let user = try await repository.getWelcomeUser()
		return "\(user.greeting), \(user.name)"
	}
}
