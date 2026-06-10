import SwiftUI

enum AppRoute: Hashable, Identifiable {
	case splash
	case home
	case welcome(showCloseButton: Bool)

	var id: String {
		String(describing: self)
	}

	var key: AppRouteKey {
		switch self {
		case .splash:
			.splash
		case .home:
			.home
		case .welcome:
			.welcome
		}
	}
}

enum AppRouteKey: Hashable {
	case splash
	case home
	case welcome
}

enum AppRouteFactory {
	@ViewBuilder
	static func make(route: AppRoute, diFactory: AppDIFactory) -> some View {
		switch route {
		case .splash:
			SplashScreen(container: diFactory.screens.makeSplashContainer())
		case .home:
			HomeScreen(container: diFactory.screens.makeHomeContainer())
		case .welcome(let showCloseButton):
			WelcomeScreen(
				title: "Welcome",
				showsCloseButton: showCloseButton,
				container: diFactory.screens.makeWelcomeContainer()
			)
		}
	}
}
