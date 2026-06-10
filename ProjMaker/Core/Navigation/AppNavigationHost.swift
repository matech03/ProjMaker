import SwiftUI
import Combine

@MainActor
struct AppNavigationHost: View {
	private let diFactory: AppDIFactory
	@State private var nav = NavigationState()

	init(diFactory: AppDIFactory) {
		self.diFactory = diFactory
	}

	var body: some View {
		CompatibleNavigationStack(
			path: $nav.rootPath,
			root: destination(for: nav.rootRoute)
				.environment(\.router, router(for: .root)),
			destination: { route in
				destination(for: route)
					.environment(\.router, router(for: .root))
			}
		)
		.sheet(item: $nav.rootSheet, onDismiss: {
			nav.rootSheet = nil
		}) { node in
			PresentationHost(
				node: node,
				context: .sheet,
				destination: destination,
				routerBuilder: router(for:)
			)
		}
		.fullScreenCover(item: $nav.rootModal, onDismiss: {
			nav.rootModal = nil
		}) { node in
			PresentationHost(
				node: node,
				context: .modal,
				destination: destination,
				routerBuilder: router(for:)
			)
		}
	}

	@ViewBuilder
	private func destination(for route: AppRoute) -> some View {
		AppRouteFactory.make(route: route, diFactory: diFactory)
	}

	private func router(for context: ContainerKind) -> (AppRoute, PresentStyle) -> Void {
		{ route, style in
			navigate(route, style, context: context)
		}
	}

	private func navigate(_ route: AppRoute, _ style: PresentStyle, context: ContainerKind) {
		if style == .modal && context == .sheet {
			Log.info("Not support show modal from sheet for route: \(route)")
			return
		}

		switch style {
		case .push:
			push(route, in: context)
		case .popTo:
			popTo(route, in: context)
		case .sheet:
			presentSheet(route, in: context)
		case .modal:
			presentModal(route, in: context)
		case .asRoot:
			setRoot(route)
		}
	}

	private func push(_ route: AppRoute, in context: ContainerKind) {
		switch context {
		case .root:
			nav.rootPath.append(route)
		case .sheet:
			appendToDeepestPath(route, in: nav.rootSheet)
		case .modal:
			appendToDeepestPath(route, in: nav.rootModal)
		}
	}

	private func popTo(_ route: AppRoute, in context: ContainerKind) {
		switch context {
		case .root:
			popTo(route, rootRoute: nav.rootRoute, path: &nav.rootPath)
		case .sheet:
			popTo(route, in: nav.rootSheet)
		case .modal:
			popTo(route, in: nav.rootModal)
		}
	}

	private func presentSheet(_ route: AppRoute, in context: ContainerKind) {
		switch context {
		case .root:
			nav.rootSheet = PresentationNode(route: route)
		case .sheet:
			if nav.rootSheet != nil {
				setChildSheet(route, in: nav.rootSheet)
			} else {
				setChildSheet(route, in: nav.rootModal)
			}
		case .modal:
			setChildSheet(route, in: nav.rootModal)
		}
	}

	private func presentModal(_ route: AppRoute, in context: ContainerKind) {
		switch context {
		case .root:
			nav.rootModal = PresentationNode(route: route)
		case .sheet:
			return
		case .modal:
			setChildModal(route, in: nav.rootModal)
		}
	}

	private func setRoot(_ route: AppRoute) {
		nav.rootRoute = route
		nav.rootPath.removeAll()
		nav.rootSheet = nil
		nav.rootModal = nil
	}

	private func appendToDeepestPath(_ route: AppRoute, in node: PresentationNode?) {
		guard let node else { return }
		if let modal = node.modal {
			appendToDeepestPath(route, in: modal)
			return
		}
		if let sheet = node.sheet {
			appendToDeepestPath(route, in: sheet)
			return
		}
		node.path.append(route)
	}

	private func popTo(_ route: AppRoute, rootRoute: AppRoute, path: inout [AppRoute]) {
		if rootRoute == route {
			path.removeAll()
			return
		}
		guard let index = path.firstIndex(of: route) else { return }
		path.removeSubrange(path.index(after: index)..<path.endIndex)
	}

	private func popTo(_ route: AppRoute, in node: PresentationNode?) {
		guard let node else { return }
		if let modal = node.modal {
			popTo(route, in: modal)
			return
		}
		if let sheet = node.sheet {
			popTo(route, in: sheet)
			return
		}
		popTo(route, rootRoute: node.route, path: &node.path)
	}

	private func setChildSheet(_ route: AppRoute, in node: PresentationNode?) {
		guard let node else { return }
		if let modal = node.modal {
			setChildSheet(route, in: modal)
			return
		}
		if let sheet = node.sheet {
			setChildSheet(route, in: sheet)
			return
		}
		node.sheet = PresentationNode(route: route)
	}

	private func setChildModal(_ route: AppRoute, in node: PresentationNode?) {
		guard let node else { return }
		if let modal = node.modal {
			setChildModal(route, in: modal)
			return
		}
		if let sheet = node.sheet {
			setChildModal(route, in: sheet)
			return
		}
		node.modal = PresentationNode(route: route)
	}
}

private enum ContainerKind {
	case root
	case sheet
	case modal
}

@MainActor
private final class PresentationNode: ObservableObject, Identifiable {
	let id = UUID()
	let route: AppRoute
	@Published var path: [AppRoute] = []
	@Published var sheet: PresentationNode?
	@Published var modal: PresentationNode?

	init(route: AppRoute) {
		self.route = route
	}
}

private struct NavigationState {
	var rootRoute: AppRoute = .splash
	var rootPath: [AppRoute] = []
	var rootSheet: PresentationNode?
	var rootModal: PresentationNode?
}

private struct CompatibleNavigationStack<Root: View, Destination: View>: View {
	@Binding var path: [AppRoute]
	let root: Root
	let destination: (AppRoute) -> Destination

	@ViewBuilder
	var body: some View {
		if #available(iOS 16.0, *) {
			NavigationStack(path: $path) {
				root.navigationDestination(for: AppRoute.self) { route in
					destination(route)
				}
			}
		} else {
			NavigationView {
				LegacyNavigationLevel(
					path: $path,
					root: AnyView(root),
					destination: { AnyView(destination($0)) }
				)
			}
			.navigationViewStyle(StackNavigationViewStyle())
		}
	}
}

private struct LegacyNavigationLevel: View {
	@Binding var path: [AppRoute]
	let root: AnyView
	let destination: (AppRoute) -> AnyView

	var body: some View {
		root.background(navigationLink)
	}

	@ViewBuilder
	private var navigationLink: some View {
		if let route = path.first {
			NavigationLink(isActive: isActiveBinding) {
				LegacyNavigationLevel(
					path: tailBinding,
					root: destination(route),
					destination: destination
				)
			} label: {
				EmptyView()
			}
			.hidden()
		}
	}

	private var isActiveBinding: Binding<Bool> {
		Binding(
			get: { !path.isEmpty },
			set: { isActive in
				if isActive == false {
					path.removeAll()
				}
			}
		)
	}

	private var tailBinding: Binding<[AppRoute]> {
		Binding(
			get: { Array(path.dropFirst()) },
			set: { newTail in
				guard let route = path.first else {
					path = newTail
					return
				}
				path = [route] + newTail
			}
		)
	}
}

private struct PresentationHost<Destination: View>: View {
	@ObservedObject var node: PresentationNode
	let context: ContainerKind
	let destination: (AppRoute) -> Destination
	let routerBuilder: (ContainerKind) -> (AppRoute, PresentStyle) -> Void

	var body: some View {
		CompatibleNavigationStack(
			path: Binding(
				get: { node.path },
				set: { node.path = $0 }
			),
			root: destination(node.route)
				.environment(\.router, routerBuilder(context)),
			destination: { route in
				destination(route)
					.environment(\.router, routerBuilder(context))
			}
		)
		.sheet(item: Binding(
			get: { node.sheet },
			set: { node.sheet = $0 }
		), onDismiss: {
			node.sheet = nil
		}) { sheetNode in
			PresentationHost(
				node: sheetNode,
				context: .sheet,
				destination: destination,
				routerBuilder: routerBuilder
			)
		}
		.fullScreenCover(item: Binding(
			get: { node.modal },
			set: { node.modal = $0 }
		), onDismiss: {
			node.modal = nil
		}) { modalNode in
			PresentationHost(
				node: modalNode,
				context: .modal,
				destination: destination,
				routerBuilder: routerBuilder
			)
		}
	}
}
