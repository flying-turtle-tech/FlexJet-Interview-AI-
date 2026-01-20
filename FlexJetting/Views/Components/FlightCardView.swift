import SwiftUI

struct FlightCardView: View {
    let viewModel: FlightCardViewModel
    let flight: Flight
    let isCompleted: Bool
    
    init(flight: Flight, isCompleted: Bool) {
        self.flight = flight
        self.isCompleted = isCompleted
        self.viewModel = FlightCardViewModel(flight: flight)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                CalendarBadgeView(date: flight.departure)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.title)
                        .font(.custom(.semiBold, relativeTo: .footnote))
                        .foregroundStyle(Color.primaryText)

                    Text(viewModel.subtitle)
                        .font(.custom(.regular, relativeTo: .footnote))
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                completionCheckmark
            }
            if viewModel.isToday {
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
                .strokeBorder(Color.tertiary, lineWidth: viewModel.isToday ? 0 : 1)
        }
        .background(
            viewModel.isToday ?
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
    )
}
