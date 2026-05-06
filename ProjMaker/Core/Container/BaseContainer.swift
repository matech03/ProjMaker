import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#else
enum UIDeviceOrientation {
	case unknown
	var isLandscape: Bool { false }
}
#endif

enum SystemIntent {
	case onAppear
	case onDisappear
	case colorSchemeChanged(ColorScheme)
	case orientationChanged(UIDeviceOrientation)
}

struct ContainerConfig {
	var trackAppear: Bool = true
	var trackDisappear: Bool = true
	var trackColorScheme: Bool = false
	var trackOrientation: Bool = false
}

@MainActor
class BaseContainer<State, Intent, Effect>: ObservableObject {
	@Published var state: State

	private let effectSubject = PassthroughSubject<Effect, Never>()
	var effects: AnyPublisher<Effect, Never> {
		effectSubject.eraseToAnyPublisher()
	}

	private var runningTasks: [String: Task<Void, Never>] = [:]

	init(initialState: State) {
		self.state = initialState
	}

	func dispatch(_ intent: Intent) async {
		fatalError("dispatch(_:) must be overridden in subclass")
	}

	func send(_ intent: Intent) {
		Task<Void, Never> {
			await dispatch(intent)
		}
	}

	func dispatchSystem(_ intent: SystemIntent) async {
	}

	func runTask(id: String, operation: @escaping @MainActor @Sendable () async -> Void) {
		runningTasks[id]?.cancel()
		runningTasks[id] = Task { @MainActor [weak self] in
			await operation()
			self?.runningTasks[id] = nil
		}
	}

	func cancelAllTasks() {
		runningTasks.values.forEach { $0.cancel() }
		runningTasks.removeAll()
	}

	func sendEffect(_ effect: Effect) {
		effectSubject.send(effect)
	}
}
