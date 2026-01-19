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
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                CalendarBadgeView(date: flight.departure)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(originCity) to \(destinationCity)")
                        .font(.custom(.semiBold, relativeTo: .footnote))
                        .foregroundStyle(Color.primaryText)

                    Text("\(departureTime) - \(arrivalTime)")
                        .font(.custom(.regular, relativeTo: .footnote))
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
                .font(.custom(.extraBold, relativeTo: .footnote))
                .foregroundStyle(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: 34))
            }
        }
        .padding(15)
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
                .font(.system(size: 24))
                .foregroundStyle(Color.accent)
        } else {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 24))
                .foregroundStyle(Color.black)
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
            origin: "Logan (BOS)",
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
