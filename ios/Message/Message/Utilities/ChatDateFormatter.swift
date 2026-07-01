import Foundation

enum ChatDateFormatter {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()

    private static let fullDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()

    static func timeString(from date: Date) -> String {
        timeFormatter.string(from: date)
    }

    static func daySeparatorTitle(for date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return fullDayFormatter.string(from: date)
        }
    }

    static func readReceiptString(from date: Date) -> String {
        "Read \(timeString(from: date))"
    }
}
