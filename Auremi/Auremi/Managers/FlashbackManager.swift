//
//  FlashbackManager.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/3/25.
//
import Foundation

class FlashbackManager {
    private let memoryManager: MemoryManager
    private let calendar = Calendar.current

    init(memoryManager: MemoryManager = MemoryManager()) {
        self.memoryManager = memoryManager
    }

    func findFlashbacks(for date: Date = Date()) -> [FlashbackMemory] {
        var flashbacks: [FlashbackMemory] = []

        // Check if user has been using app for at least 7 days
        guard let firstEntryDate = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.firstEntryDate) as? Date else {
            return []
        }

        let daysSinceStart = calendar.dateComponents([.day], from: firstEntryDate, to: date).day ?? 0
        guard daysSinceStart >= 7 else { return [] }

        // Check various time periods
        let periods: [(component: Calendar.Component, value: Int, period: FlashbackMemory.TimePeriod)] = [
            (.day, -7, .oneWeek),
            (.month, -1, .oneMonth),
            (.month, -3, .threeMonths),
            (.month, -6, .sixMonths),
            (.year, -1, .oneYear),
            (.year, -2, .multipleYears(2)),
            (.year, -3, .multipleYears(3)),
            (.year, -4, .multipleYears(4)),
            (.year, -5, .multipleYears(5))
        ]

        for (component, value, period) in periods {
            if let targetDate = calendar.date(byAdding: component, value: value, to: date),
               let memory = memoryManager.getMemory(for: targetDate) {
                let flashback = FlashbackMemory(
                    id: memory.id ?? UUID(),
                    memory: memory,
                    timePeriod: period
                )
                flashbacks.append(flashback)
            }
        }

        return flashbacks
    }

    func getRandomFlashback() -> FlashbackMemory? {
        let allMemories = memoryManager.getAllMemories()

        guard !allMemories.isEmpty else { return nil }

        // Filter out recent memories (last 7 days)
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let oldMemories = allMemories.filter { memory in
            let memoryDate = memory.date
            return memoryDate < sevenDaysAgo
        }

        guard let randomMemory = oldMemories.randomElement() else { return nil }

        // Calculate time period
        let memoryDate = randomMemory.date
        let components = calendar.dateComponents([.year, .month, .day], from: memoryDate, to: Date())

        let period: FlashbackMemory.TimePeriod
        if let years = components.year, years > 0 {
            period = years == 1 ? .oneYear : .multipleYears(years)
        } else if let months = components.month, months > 0 {
            if months >= 6 {
                period = .sixMonths
            } else if months >= 3 {
                period = .threeMonths
            } else {
                period = .oneMonth
            }
        } else {
            period = .oneWeek
        }

        return FlashbackMemory(
            id: randomMemory.id ?? UUID(),
            memory: randomMemory,
            timePeriod: period
        )
    }
}
