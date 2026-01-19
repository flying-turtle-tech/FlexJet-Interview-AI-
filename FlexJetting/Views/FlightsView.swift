import SwiftUI

struct FlightsView: View {
    @StateObject private var viewModel: FlightsViewModel
    @EnvironmentObject private var flightCompletionManager: FlightCompletionManager

    init(flightService: FlightService) {
        _viewModel = StateObject(wrappedValue: FlightsViewModel(flightService: flightService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filter", selection: $viewModel.selectedFilter) {
                    ForEach(FlightFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                content
            }
            .navigationTitle("Flights")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Add flight action - placeholder
                    } label: {
                        Image(systemName: "plus.square.fill")
                            .font(.title3)
                    }
                }
            }
            .task {
                await viewModel.fetchFlights()
            }
            .refreshable {
                await viewModel.fetchFlights()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.flights.isEmpty {
            Spacer()
            ProgressView()
            Spacer()
        } else if let errorMessage = viewModel.errorMessage, viewModel.flights.isEmpty {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)

                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Try Again") {
                    Task {
                        await viewModel.fetchFlights()
                    }
                }
                .buttonStyle(.bordered)
            }
            Spacer()
        } else if viewModel.filteredFlights.isEmpty {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "airplane")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)

                Text("No \(viewModel.selectedFilter.rawValue.lowercased()) flights")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            Spacer()
        } else {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.filteredFlights) { flight in
                        NavigationLink(value: flight) {
                            FlightCardView(
                                flight: flight,
                                isCompleted: flightCompletionManager.isCompleted(flight.id),
                                isToday: viewModel.isFlightToday(flight),
                            )
                            .padding(.horizontal, 17)
                            .padding(.vertical, 7.5)
                        }
                    }
                }
            }
            .navigationDestination(for: Flight.self) { flight in
                FlightDetailView(flight: flight)
            }
        }
    }
}
