//
//  StreakManager.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/1/25.
//

import Foundation
import Combine

class StreakManager: ObservableObject {
    static let shared = StreakManager()

    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var longestStreak: Int = 0

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current

    private init() {
        recalculateStreaks()
    }

    func getStreak() -> Streak {
        let startDate = defaults.object(forKey: AppConstants.UserDefaultsKeys.firstEntryDate) as? Date
        let lastDate = defaults.object(forKey: "lastEntryDate") as? Date

        return Streak(
            current: currentStreak,
            longest: longestStreak,
            startDate: startDate,
            lastEntryDate: lastDate
        )
    }

    func updateStreak(for date: Date) {
        // Update last entry date
        defaults.set(date, forKey: "lastEntryDate")

        // Set first entry date if not exists
        if defaults.object(forKey: AppConstants.UserDefaultsKeys.firstEntryDate) == nil {
            defaults.set(date, forKey: AppConstants.UserDefaultsKeys.firstEntryDate)
        }

        // Recalculate streaks from actual data
        recalculateStreaks()
    }

    func recalculateStreaks() {
        let memoryManager = MemoryManager()
        let allMemories = memoryManager.getAllMemories()

        guard !allMemories.isEmpty else {
            currentStreak = 0
            longestStreak = 0
            return
        }

        // Get all memory dates (unique days only)
        let memoryDates = Set(allMemories.compactMap { memory -> Date? in
            let date = memory.date
            return calendar.startOfDay(for: date)
        }).sorted(by: >)

        guard !memoryDates.isEmpty else {
            currentStreak = 0
            longestStreak = 0
            return
        }

        // Calculate current streak (from today backwards)
        let today = calendar.startOfDay(for: Date())
        var current = 0

        // Check if there's an entry for today or yesterday (streak is active)
        if memoryDates.contains(today) {
            current = calculateStreakFrom(date: today, memoryDates: memoryDates)
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  memoryDates.contains(yesterday) {
            current = calculateStreakFrom(date: yesterday, memoryDates: memoryDates)
        }

        // Calculate longest streak ever
        var longest = 0
        var tempStreak = 0
        var previousDate: Date?

        for date in memoryDates.reversed() { // Process from oldest to newest
            if let prevDate = previousDate {
                let daysBetween = calendar.dateComponents([.day], from: prevDate, to: date).day ?? 0

                if daysBetween == 1 {
                    // Consecutive day
                    tempStreak += 1
                } else {
                    // Streak broken
                    longest = max(longest, tempStreak)
                    tempStreak = 1
                }
            } else {
                // First date
                tempStreak = 1
            }

            previousDate = date
        }

        // Don't forget the last streak
        longest = max(longest, tempStreak)

        // Update published properties
        currentStreak = current
        longestStreak = max(longest, current) // Ensure longest is at least current

        // Save to UserDefaults
        defaults.set(currentStreak, forKey: AppConstants.UserDefaultsKeys.currentStreak)
        defaults.set(longestStreak, forKey: AppConstants.UserDefaultsKeys.longestStreak)
    }

    private func calculateStreakFrom(date: Date, memoryDates: [Date]) -> Int {
        var streak = 0
        var checkDate = date

        while memoryDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }

    func resetStreak() {
        currentStreak = 0
        longestStreak = 0
        defaults.set(0, forKey: AppConstants.UserDefaultsKeys.currentStreak)
        defaults.set(0, forKey: AppConstants.UserDefaultsKeys.longestStreak)
        defaults.removeObject(forKey: AppConstants.UserDefaultsKeys.firstEntryDate)
        defaults.removeObject(forKey: "lastEntryDate")
    }

    func getStreakHistory(for days: Int = 30) -> [Date: Bool] {
        let memoryManager = MemoryManager()
        var history: [Date: Bool] = [:]

        for dayOffset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let hasEntry = memoryManager.getMemory(for: date) != nil
                history[date] = hasEntry
            }
        }

        return history
    }
}
