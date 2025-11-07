//
//  Streak.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//

import Foundation

struct Streak: Codable {
    let current: Int
    let longest: Int
    let startDate: Date?
    let lastEntryDate: Date?

    var isActive: Bool {
        guard let lastDate = lastEntryDate else { return false }
        let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        return daysSince <= 1
    }

    var streakEmoji: String {
        switch current {
        case 0: return "🌱"
        case 1...2: return "🔥"
        case 3...6: return "🔥🔥"
        case 7...13: return "🔥🔥🔥"
        case 14...29: return "⚡️"
        case 30...99: return "💫"
        default: return "🌟"
        }
    }

    var encouragementMessage: String {
        switch current {
        case 0: return "Start your journey today!"
        case 1: return "Great start! Keep going!"
        case 2...6: return "You're building momentum!"
        case 7: return "One week strong! 🎉"
        case 14: return "Two weeks! Amazing!"
        case 30: return "One month! Incredible! 🎊"
        case 50: return "50 days! You're unstoppable!"
        case 100: return "100 DAYS! LEGENDARY! 👑"
        default: return "Keep the streak alive!"
        }
    }
}
