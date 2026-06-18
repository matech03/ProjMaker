import Foundation

@propertyWrapper
final class KeyValueBinding<Value> {
	private let key: String
	private let defaultValue: Value
	private let userDefaults = UserDefaults(suiteName: AppInfo.appGroup) ?? .standard

	init(key: String, defaultValue: Value) {
		self.key = key
		self.defaultValue = defaultValue
	}

	var wrappedValue: Value {
		get {
			userDefaults.object(forKey: key) as? Value ?? defaultValue
		}
		set {
			if let optional = newValue as? AnyOptional {
				guard let unwrappedValue = optional.wrappedValue else {
					userDefaults.removeObject(forKey: key)
					return
				}
				userDefaults.set(unwrappedValue, forKey: key)
				return
			}
			userDefaults.set(newValue, forKey: key)
		}
	}
}

private protocol AnyOptional {
	var wrappedValue: Any? { get }
}

extension Optional: AnyOptional {
	var wrappedValue: Any? {
		switch self {
		case .none:
			return nil
		case .some(let value):
			return value
		}
	}
}
