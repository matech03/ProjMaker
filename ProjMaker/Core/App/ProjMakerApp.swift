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
	private let diFactory = AppDIFactory()

	var body: some Scene {
		WindowGroup {
			AppNavigationHost(diFactory: diFactory)
		}
	}
}
