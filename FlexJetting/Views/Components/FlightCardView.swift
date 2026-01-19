import SwiftUI

struct FlightCardView: View {
    let flight: Flight
    let isCompleted: Bool
    let isToday: Bool

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = .current
        return formatter
    }()

    private var departureTime: String {
        Self.timeFormatter.string(from: flight.departure)
    }

    private var arrivalTime: String {
        Self.timeFormatter.string(from: flight.arrival)
    }

    private var originCity: String {
        extractCity(from: flight.origin)
    }

    private var destinationCity: String {
        extractCity(from: flight.destination)
    }

    private func extractCity(from location: String) -> String {
        if let parenIndex = location.firstIndex(of: "(") {
            return String(location[..<parenIndex]).trimmingCharacters(in: .whitespaces)
        }
        return location
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                CalendarBadgeView(date: flight.departure)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(originCity) to \(destinationCity)")
                            .font(.headline)
                            .foregroundStyle(Color.primaryText)
                    }

                    Text("\(departureTime) - \(arrivalTime)")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                completionCheckmark
            }
            if isToday {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                    Text("Flight Today")
                }
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
                    .background(Color.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 34))
            }
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.tertiary, lineWidth: isToday ? 0 : 1)
        }
        .background(
            isToday ?
            RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: Color.black.opacity(0.09), radius: 5.3, x: 0, y: 2)
            : nil
            )
    }

    @ViewBuilder
    private var completionCheckmark: some View {
        if isCompleted {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundColor(Color(red: 0.573, green: 0.149, blue: 0.173))
        } else {
            Image(systemName: "checkmark.seal")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    FlightCardView(
        flight: Flight(
            id: "1234",
            tripNumber: "1000015",
            flightNumber: "FLEX25",
            tailNumber: "UA23",
            origin: "Logan International (BOS)",
            originIata: "BOS",
            destination: "New York (JFK)",
            destinationIata: "JFK",
            departure: Date.now.advanced(by: 100),
            arrival: Date.now.advanced(by: 500),
            price: 13000
        ),
        isCompleted: false,
        isToday: true,
    )
}
