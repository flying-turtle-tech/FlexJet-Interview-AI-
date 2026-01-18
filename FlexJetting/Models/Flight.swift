import Foundation

struct Flight: Codable, Identifiable, Equatable {
    let id: String
    let tripNumber: String
    let flightNumber: String?
    let tailNumber: String
    let origin: String
    let originIata: String
    let destination: String
    let destinationIata: String
    let departure: Date
    let arrival: Date
    let price: Int

    var priceInDollars: Double {
        Double(price) / 100.0
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: priceInDollars)) ?? "$0.00"
    }

    var duration: TimeInterval {
        arrival.timeIntervalSince(departure)
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
