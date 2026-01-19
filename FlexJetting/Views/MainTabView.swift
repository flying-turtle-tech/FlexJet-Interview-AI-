import SwiftUI

struct MainTabView: View {
    private let flightService: FlightService

    init(flightService: FlightService) {
        self.flightService = flightService
    }

    var body: some View {
        TabView {
            FlightsView(flightService: flightService)
                .tabItem {
                    Label("Flights", systemImage: "airplane")
                }

            PlaceholderView(title: "Favorites")
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                        .environment(\.symbolVariants, .none)
                }

            PlaceholderView(title: "Contracts")
                .tabItem {
                    Label("Contracts", systemImage: "signature")
                }

            PlaceholderView(title: "Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

private struct PlaceholderView: View {
    let title: String
    @EnvironmentObject private var authState: AuthState

    var body: some View {
        NavigationStack {
            Text("Coming Soon")
                .foregroundStyle(.secondary)
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Logout") {
                            authState.signOut()
                        }
                    }
                }
        }
    }
}
