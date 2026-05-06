import Foundation

@MainActor
final class RepositoryDIFactory {
	private let services: ServiceDIFactory

	init(services: ServiceDIFactory) {
		self.services = services
	}

	lazy var welcomeRepository: WelcomeRepository = {
		DefaultWelcomeRepository(service: services.welcomeService)
	}()
}
