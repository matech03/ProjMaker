import Foundation

protocol WelcomeRepository {
	func getWelcomeUser() async throws -> WelcomeUser
}
