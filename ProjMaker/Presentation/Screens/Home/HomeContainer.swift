import Foundation

struct HomeActionItem: Identifiable, Hashable {
	let kind: HomeActionKind
	let title: String

	var id: HomeActionKind { kind }
}

enum HomeActionKind: Hashable {
	case alert
	case push
	case modal
	case sheet
}

struct HomeState {
	let actions: [HomeActionItem] = [
		HomeActionItem(kind: .alert, title: "Show Alert"),
		HomeActionItem(kind: .push, title: "Show Push"),
		HomeActionItem(kind: .modal, title: "Show Modal"),
		HomeActionItem(kind: .sheet, title: "Show Sheet")
	]
}

enum HomeIntent {
	case tapAction(HomeActionItem)
}

enum HomeEffect {
	case showWelcomeAlert
	case navigate(route: AppRoute, style: PresentStyle)
}

@MainActor
final class HomeContainer: BaseContainer<HomeState, HomeIntent, HomeEffect> {
	init() {
		super.init(initialState: HomeState())
	}

	override func dispatch(_ intent: HomeIntent) async {
		switch intent {
		case let .tapAction(item):
			handleAction(item)
		}
	}
	
	override func dispatchSystem(_ intent: SystemIntent) async {
		Log.info("systemIntent = \(intent)")
	}

	private func handleAction(_ item: HomeActionItem) {
		switch item.kind {
		case .alert:
			sendEffect(.showWelcomeAlert)
		case .push:
			sendEffect(.navigate(route: .welcome(showCloseButton: false), style: .push))
		case .modal:
			sendEffect(.navigate(route: .welcome(showCloseButton: true), style: .modal))
		case .sheet:
			sendEffect(.navigate(route: .welcome(showCloseButton: false), style: .sheet))
		}
	}
}
