//
//  StreakManager.swift
//  MemorySparks
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
        loadStreakData()
    }

    private func loadStreakData() {
        currentStreak = defaults.integer(forKey: AppConstants.UserDefaultsKeys.currentStreak)
        longestStreak = defaults.integer(forKey: AppConstants.UserDefaultsKeys.longestStreak)
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
        let lastEntryDate = defaults.object(forKey: "lastEntryDate") as? Date
        let today = calendar.startOfDay(for: date)

        if let lastDate = lastEntryDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 0 {
                // Same day - don't change streak
                return
            } else if daysBetween == 1 {
                // Consecutive day - increment streak
                currentStreak += 1
                defaults.set(currentStreak, forKey: AppConstants.UserDefaultsKeys.currentStreak)

                // Update longest streak if necessary
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                    defaults.set(longestStreak, forKey: AppConstants.UserDefaultsKeys.longestStreak)
                }
            } else {
                // Streak broken - reset to 1
                currentStreak = 1
                defaults.set(1, forKey: AppConstants.UserDefaultsKeys.currentStreak)
            }
        } else {
            // First entry ever
            currentStreak = 1
            longestStreak = 1
            defaults.set(1, forKey: AppConstants.UserDefaultsKeys.currentStreak)
            defaults.set(1, forKey: AppConstants.UserDefaultsKeys.longestStreak)
            defaults.set(date, forKey: AppConstants.UserDefaultsKeys.firstEntryDate)
        }

        defaults.set(date, forKey: "lastEntryDate")
    }

    func resetStreak() {
        currentStreak = 0
        defaults.set(0, forKey: AppConstants.UserDefaultsKeys.currentStreak)
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
