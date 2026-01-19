import SwiftUI

struct FlightsView: View {
    @StateObject private var viewModel: FlightsViewModel
    @EnvironmentObject private var flightCompletionManager: FlightCompletionManager
    @State private var addFlight: Bool = false

    init(flightService: FlightService) {
        _viewModel = StateObject(wrappedValue: FlightsViewModel(flightService: flightService))
    }
    
    private var titleView: some View {
        HStack {
            Text("Flights").font(.custom(.semiBold, relativeTo: .title2))
            Spacer()
            Button("", systemImage: "plus.square.fill") {
                addFlight = true
            }.font(.system(size: 24))
            .alert("Not Supported", isPresented: $addFlight) {
                Button("OK", role: .cancel) {
                    addFlight = false
                }
            } message: {
                Text("This action is not yet supported. Please try again later.")
            }
        }
        .padding(.horizontal, 30)
    }

    var body: some View {
        NavigationStack {
            titleView
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
                    .foregroundStyle(.secondary)

                Text(errorMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)

                Text("No \(viewModel.selectedFilter.rawValue.lowercased()) flights")
                    .font(.body)
                    .foregroundStyle(.secondary)
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
