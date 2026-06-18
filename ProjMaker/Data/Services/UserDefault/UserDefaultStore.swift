import Foundation

final class UserDefaultStore {
	@KeyValueBinding(key: "first-open", defaultValue: true)
	static var firstOpen: Bool

	private init() {}
}
