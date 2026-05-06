import Foundation

struct DefaultWelcomeRepository: WelcomeRepository {
	private let service: WelcomeService

	init(service: WelcomeService) {
		self.service = service
	}

	func getWelcomeUser() async throws -> WelcomeUser {
		let dto = try await service.fetchWelcomeUser()
		return WelcomeUser(name: dto.name, greeting: dto.greeting)
	}
}
