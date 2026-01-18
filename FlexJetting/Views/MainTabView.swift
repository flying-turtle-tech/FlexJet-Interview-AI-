import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

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

    var body: some View {
        NavigationStack {
            Text("Coming Soon")
                .foregroundColor(.secondary)
                .navigationTitle(title)
        }
    }
}
