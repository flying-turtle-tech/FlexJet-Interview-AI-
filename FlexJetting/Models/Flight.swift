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

    var priceInDollars: Int {
        price / 100
    }

    var formattedPrice: String {
        return "$\(priceInDollars)"
    }
}
