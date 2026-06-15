import Foundation

protocol WelcomeService {
	func fetchWelcomeUser() async throws -> WelcomeUser
}

struct MockWelcomeService: WelcomeService {
	private let greetings: [String] = [
		"Welcome",
		"Welcome back",
		"Hi",
		"Hello",
		"Hi there",
	]
	func fetchWelcomeUser() async throws -> WelcomeUser {
		let name = AppInfo.appName
		try await Task.sleep(nanoseconds: 180_000_000)
		return WelcomeUser(name: name, greeting: greetings.randomElement()!)
	}
}
