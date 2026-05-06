import Foundation

@MainActor
final class ServiceDIFactory {
	lazy var welcomeService: WelcomeService = MockWelcomeService()
}
