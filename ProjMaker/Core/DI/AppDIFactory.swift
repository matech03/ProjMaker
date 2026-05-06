import Foundation

@MainActor
final class AppDIFactory {
	let services: ServiceDIFactory
	let repositories: RepositoryDIFactory
	let useCases: UseCaseDIFactory
	let screens: ScreenDIFactory

	init() {
		let services = ServiceDIFactory()
		let repositories = RepositoryDIFactory(services: services)
		let useCases = UseCaseDIFactory(repositories: repositories)
		let screens = ScreenDIFactory(useCases: useCases)

		self.services = services
		self.repositories = repositories
		self.useCases = useCases
		self.screens = screens
	}
}
