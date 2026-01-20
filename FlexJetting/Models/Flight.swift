import Foundation

struct Flight: Codable, Identifiable, Equatable, Hashable {
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

    static let placeholder = Flight(
        id: "placeholder",
        tripNumber: "0000",
        flightNumber: "000",
        tailNumber: "N0000",
        origin: "Placeholder City",
        originIata: "PLH",
        destination: "Destination City",
        destinationIata: "DST",
        departure: Date(),
        arrival: Date().addingTimeInterval(3600),
        price: 0
    )
}
extension Flight {
    var priceInDollars: Int {
        price / 100
    }

    var formattedPrice: String {
        return "$\(priceInDollars)"
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(departure) && departure >= Date()
    }
    
    func extractCity(from location: String) -> String {
        if let parenIndex = location.firstIndex(of: "(") {
            return String(location[..<parenIndex]).trimmingCharacters(in: .whitespaces)
        }
        return location
    }
    
    var originCity: String {
        extractCity(from: origin)
    }

    var destinationCity: String {
        extractCity(from: destination)
    }
}
