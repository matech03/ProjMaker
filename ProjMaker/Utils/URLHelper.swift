import UIKit

enum URLHelper {
	@discardableResult
	@MainActor
	static func open(_ url: URL) -> Bool {
		guard UIApplication.shared.canOpenURL(url) else { return false }
		UIApplication.shared.open(url)
		return true
	}

	@discardableResult
	@MainActor
	static func openSettings() -> Bool {
		guard let url = URL(string: UIApplication.openSettingsURLString) else { return false }
		return open(url)
	}

	static func webURL(from value: String) -> URL? {
		let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedValue.isEmpty else { return nil }

		let urlString = trimmedValue.contains("://") ? trimmedValue : "https://\(trimmedValue)"
		guard let url = URL(string: urlString), let scheme = url.scheme?.lowercased() else { return nil }
		guard scheme == "http" || scheme == "https" else { return nil }
		guard url.host?.isEmpty == false else { return nil }
		return url
	}

	static func phoneURL(from phoneNumber: String) -> URL? {
		let allowedCharacters = CharacterSet(charactersIn: "+0123456789")
		let normalizedValue = phoneNumber.unicodeScalars.filter { allowedCharacters.contains($0) }.map(String.init).joined()
		guard !normalizedValue.isEmpty else { return nil }
		return URL(string: "tel://\(normalizedValue)")
	}

	static func emailURL(to address: String, subject: String? = nil, body: String? = nil) -> URL? {
		let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedAddress.isEmpty else { return nil }

		var components = URLComponents()
		components.scheme = "mailto"
		components.path = trimmedAddress

		var queryItems: [URLQueryItem] = []
		if let subject, !subject.isEmpty {
			queryItems.append(URLQueryItem(name: "subject", value: subject))
		}
		if let body, !body.isEmpty {
			queryItems.append(URLQueryItem(name: "body", value: body))
		}
		components.queryItems = queryItems.isEmpty ? nil : queryItems

		return components.url
	}
}
