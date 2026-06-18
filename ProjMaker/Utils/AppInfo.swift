import Foundation

enum AppInfo {
	static var appName: String {
		return value(for: "CFBundleDisplayName")
			?? value(for: "CFBundleName")
			?? "App"
	}

	static var version: String {
		return value(for: "CFBundleShortVersionString") ?? ""
	}

	static var build: String {
		return value(for: kCFBundleVersionKey as String) ?? ""
	}

	static var bundleIdentifier: String {
		return Bundle.main.bundleIdentifier ?? ""
	}

	static var appGroup: String {
		if let configuredAppGroup = value(for: "AppGroupIdentifier"), configuredAppGroup.isEmpty == false {
			return configuredAppGroup
		}
		let identifier = bundleIdentifier.isEmpty ? "com.example.ProjMaker" : bundleIdentifier
		return "group.\(identifier)"
	}

	static var versionAndBuild: String {
		guard !version.isEmpty else { return build }
		guard !build.isEmpty else { return version }
		return "\(version) (\(build))"
	}

	private static func value(for key: String) -> String? {
		return Bundle.main.localizedInfoDictionary?[key] as? String
			?? Bundle.main.infoDictionary?[key] as? String
	}
}
