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
        HStack(spacing: 12) {
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
            HStack(spacing: 8) {
                Image(systemName: isCompleted ? "checkmark.seal.fill" : "checkmark.seal")
                Text(isCompleted ? "Completed" : "Complete")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(isCompleted ? .white : .primary)
            .background(
                isCompleted
                ? Color.accentColor
                : Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isCompleted ? Color.clear : Color.gray,
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                .font(.headline)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
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
                .fontWeight(.medium)
            Spacer()

            Text(value)
                .foregroundStyle(.primaryText)
                .fontWeight(.medium)
        }
    }
}
