//
//  StreakCalendarView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/3/25.
//

import SwiftUI

struct StreakCalendarView: View {
    let history: [Date: Bool]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(sortedDates(), id: \.self) { date in
                DayCell(date: date, hasEntry: history[date] ?? false)
            }
        }
    }

    private func sortedDates() -> [Date] {
        history.keys.sorted(by: >)
    }
}

struct DayCell: View {
    let date: Date
    let hasEntry: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(DateFormatter.dayOfMonth(from: date))
                .font(.caption2)
                .fontWeight(.medium)

            Circle()
                .fill(hasEntry ? Color.orange : Color(.systemGray5))
                .frame(width: 8, height: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(hasEntry ? Color.orange.opacity(0.1) : Color.clear)
        )
    }
}
