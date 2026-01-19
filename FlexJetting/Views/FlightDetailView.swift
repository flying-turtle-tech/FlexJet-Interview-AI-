import SwiftUI

struct FlightDetailView: View {
    let flight: Flight
    @EnvironmentObject private var flightCompletionManager: FlightCompletionManager

    private var isCompleted: Bool {
        flightCompletionManager.isCompleted(flight.id)
    }

    private var formattedDepartureDate: String {
        flight.departure.formatted(.dateTime.month(.abbreviated).day())
    }

    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: flight.departure, relativeTo: Date())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                airportCards

                detailRows

                Spacer(minLength: 24)

                completeButton
            }
            .padding()
        }
        .navigationTitle("\(flight.originIata) to \(flight.destinationIata)")
        .navigationBarTitleDisplayMode(.large)
    }

    private var airportCards: some View {
        HStack(spacing: 16) {
            AirportCard(
                airport: flight.origin,
                label: "Origin"
            )

            AirportCard(
                airport: flight.destination,
                label: "Destination"
            )
        }
    }

    private var detailRows: some View {
        VStack(spacing: 16) {
            DetailRow(label: "Departure", value: "\(formattedDepartureDate) (\(relativeTime))")
            DetailRow(label: "Trip Number", value: flight.tripNumber)

            if let flightNumber = flight.flightNumber {
                DetailRow(label: "Flight Number", value: flightNumber)
            }

            DetailRow(label: "Tail Number", value: flight.tailNumber)
            DetailRow(label: "Price", value: flight.formattedPrice)
        }
    }

    private var completeButton: some View {
        Button {
            flightCompletionManager.toggle(flight.id)
        } label: {
            if isCompleted {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Completed")
                        .font(.custom(.semiBold, relativeTo: .footnote))
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .background(Color.accent)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                HStack {
                    Image(systemName: "checkmark.seal")
                    Text("Complete")
                        .font(.custom(.semiBold, relativeTo: .footnote))
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .background(Color.white)
                .foregroundStyle(Color.black)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.tertiary, lineWidth: 1)
                }
            }
        }
        .disabled(flight.departure > Date.now)
        .buttonStyle(.plain)
    }
}

private struct AirportCard: View {
    let airport: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(airport)
                .font(.custom(.semiBold, relativeTo: .footnote))

            Text(label)
                .font(.custom(.regular, relativeTo: .footnote))
                .foregroundStyle(.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.tertiary, lineWidth: 1)
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondaryText)
            Spacer()

            Text(value)
                .foregroundStyle(.primaryText)
        }.font(.custom(.semiBold, relativeTo: .subheadline))
    }
}
