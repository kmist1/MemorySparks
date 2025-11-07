//
//  FlashbackMemory.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//

import Foundation

struct FlashbackMemory: Identifiable {
    let id: UUID
    let memory: Memory
    let timePeriod: TimePeriod

    enum TimePeriod {
        case oneWeek
        case oneMonth
        case threeMonths
        case sixMonths
        case oneYear
        case multipleYears(Int)

        var description: String {
            switch self {
            case .oneWeek:
                return "1 week ago"
            case .oneMonth:
                return "1 month ago"
            case .threeMonths:
                return "3 months ago"
            case .sixMonths:
                return "6 months ago"
            case .oneYear:
                return "1 year ago"
            case .multipleYears(let years):
                return "\(years) years ago"
            }
        }

        var emoji: String {
            switch self {
            case .oneWeek:
                return "📅"
            case .oneMonth:
                return "🗓️"
            case .threeMonths:
                return "🌸"
            case .sixMonths:
                return "🍂"
            case .oneYear:
                return "🎂"
            case .multipleYears:
                return "🎊"
            }
        }
    }
}
