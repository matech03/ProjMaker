import Foundation

struct DefaultWelcomeRepository: WelcomeRepository {
	private let service: WelcomeService

	init(service: WelcomeService) {
		self.service = service
	}

	func getWelcomeUser() async throws -> WelcomeUser {
		try await service.fetchWelcomeUser()
	}
}
