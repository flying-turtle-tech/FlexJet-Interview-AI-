import SwiftUI

struct CalendarBadgeView: View {
    let date: Date
    
    private var isPast: Bool {
        Date.now > date
    }

    private var monthAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }

    private var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(monthAbbreviation)
                .frame(width: 48, height: 18)
                .font(.custom(.extraBold, relativeTo: .caption))
                .foregroundStyle(isPast ? Color.secondaryText : .accent)
                .background(isPast ? Color.tertiary : .accent.opacity(0.18))
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4))

            Text(dayOfMonth)
                .frame(width: 48, height: 30)
                .font(.custom(.extraBold, relativeTo: .caption))
                .background(Color.offWhite)
                .foregroundStyle(Color.primaryText)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4))
            
        }
        .frame(width: 48, height: 48)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CalendarBadgeView(date: Date())
}
