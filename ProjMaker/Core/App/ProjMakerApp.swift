//
//  ProjMakerApp.swift
//  ProjMaker
//
//  Created by Lý on 20/4/26.
//

import SwiftUI

@main
@MainActor
struct ProjMakerApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	@Environment(\.scenePhase) private var scenePhase
	@State private var previousScenePhase: ScenePhase?

	private let diFactory = AppDIFactory()

	var body: some Scene {
		WindowGroup {
			AppNavigationHost(diFactory: diFactory)
		}
		.onChange(of: scenePhase) { newPhase in
			handleScenePhaseChange(newPhase)
		}
	}

	private func handleScenePhaseChange(_ scenePhase: ScenePhase) {
		let oldPhase = previousScenePhase
		previousScenePhase = scenePhase

		if oldPhase == .background, scenePhase != .background {
			Log.info("App will enter foreground", category: "app-lifecycle")
		}

		switch scenePhase {
		case .active:
			Log.info("App did become active", category: "app-lifecycle")
		case .inactive:
			if oldPhase != .background {
				Log.info("App will resign active", category: "app-lifecycle")
			}
		case .background:
			Log.info("App did enter background", category: "app-lifecycle")
		@unknown default:
			Log.info("App scene phase changed", category: "app-lifecycle")
		}
	}
}
