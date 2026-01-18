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
        HStack(spacing: 12) {
            CalendarBadgeView(date: flight.departure)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("\(originCity) to \(destinationCity)")
                        .font(.headline)

                    if isToday {
                        Text("Today")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }

                Text("\(departureTime) - \(arrivalTime)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            completionCheckmark
        }
        .padding(.vertical, 8)
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
