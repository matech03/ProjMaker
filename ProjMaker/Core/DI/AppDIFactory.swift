import Foundation

@MainActor
final class AppDIFactory {
	let services: ServiceDIFactory
	let repositories: RepositoryDIFactory
	let screens: ScreenDIFactory

	init() {
		let services = ServiceDIFactory()
		let repositories = RepositoryDIFactory(services: services)
		let screens = ScreenDIFactory(repositories: repositories)

		self.services = services
		self.repositories = repositories
		self.screens = screens
	}
}
