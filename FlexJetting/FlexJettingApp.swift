//
//  FlexJettingApp.swift
//  FlexJetting
//
//  Created by Jonathan on 1/18/26.
//

import SwiftUI

@main
struct FlexJettingApp: App {
    @StateObject private var authState = ServiceContainer.shared.authState
    @StateObject private var flightCompletionManager = ServiceContainer.shared.flightCompletionManager

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authState)
                .environmentObject(flightCompletionManager)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var authState: AuthState

    private let services = ServiceContainer.shared

    var body: some View {
        Group {
            if authState.isAuthenticated {
                MainTabView(flightService: services.flightService)
            } else {
                LoginView(
                    authenticationService: services.authenticationService,
                    onLoginSuccess: {
                        authState.checkAuthenticationStatus()
                    }
                )
            }
        }
        .animation(.easeInOut, value: authState.isAuthenticated)
    }
}
