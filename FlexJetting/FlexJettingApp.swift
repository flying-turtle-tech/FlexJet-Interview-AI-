//
//  FlexJettingApp.swift
//  FlexJetting
//
//  Created by Jonathan on 1/18/26.
//

import SwiftUI

@main
struct FlexJettingApp: App {
    @StateObject private var appState = ServiceContainer.shared.appState

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    private let services = ServiceContainer.shared

    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView(flightService: services.flightService)
            } else {
                LoginView(
                    authenticationService: services.authenticationService,
                    onLoginSuccess: {
                        appState.checkAuthenticationStatus()
                    }
                )
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}
