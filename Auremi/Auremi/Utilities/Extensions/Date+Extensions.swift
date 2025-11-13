//
//  Date+Extensions.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/1/25.
//

import Foundation

extension DateFormatter {
    static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    static func shortDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    static func relativeDate(from date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}

extension DateFormatter {
    static func dayOfMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    static func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
