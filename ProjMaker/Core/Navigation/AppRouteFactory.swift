import SwiftUI

enum AppRoute: Hashable, Identifiable {
	case splash
	case home
	case welcome(showCloseButton: Bool)

	var id: String {
		String(describing: self)
	}
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
