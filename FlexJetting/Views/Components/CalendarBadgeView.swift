import SwiftUI

struct CalendarBadgeView: View {
    let date: Date

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
        VStack(spacing: 2) {
            Text(monthAbbreviation)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text(dayOfMonth)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(width: 48, height: 48)
    }
}
