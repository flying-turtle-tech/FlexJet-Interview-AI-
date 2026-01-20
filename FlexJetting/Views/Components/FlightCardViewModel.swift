//
//  FlightCardViewModel.swift
//  FlexJetting
//
//  Created by Jonathan on 1/19/26.
//

import Foundation

struct FlightCardViewModel {    
    let title: String
    let subtitle: String
    let isToday: Bool
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = .current
        return formatter
    }()
    
    init(flight: Flight) {
        title = "\(flight.originCity) to \(flight.destinationCity)"
        subtitle = "\(Self.timeFormatter.string(from: flight.departure)) - \(Self.timeFormatter.string(from: flight.arrival))"
        isToday = flight.isToday
    }
}
