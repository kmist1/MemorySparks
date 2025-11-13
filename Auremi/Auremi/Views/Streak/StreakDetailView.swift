//
//  StreakDetailView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/3/25.
//

import SwiftUI

struct StreakDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var streakManager = StreakManager.shared

    var streak: Streak {
        streakManager.getStreak()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Main Streak Display
                    streakHeader

                    // Stats Cards
                    statsSection

                    // Calendar View
                    calendarSection

                    // Encouragement
                    encouragementSection
                }
                .padding()
            }
            .navigationTitle("Your Streak")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var streakHeader: some View {
        VStack(spacing: 16) {
            Text(streak.streakEmoji)
                .font(.system(size: 80))

            Text("\(streak.current)")
                .font(.system(size: 60, weight: .bold))

            Text("Day Streak")
                .font(.title3)
                .foregroundColor(.secondary)

            if !streak.isActive {
                Text("Streak ended - start again today!")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Current",
                value: "\(streak.current)",
                icon: "flame.fill",
                color: .orange
            )

            StatCard(
                title: "Longest",
                value: "\(streak.longest)",
                icon: "star.fill",
                color: .yellow
            )
        }
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last 30 Days")
                .font(.headline)

            StreakCalendarView(history: streakManager.getStreakHistory(for: 30))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    private var encouragementSection: some View {
        VStack(spacing: 12) {
            Text(streak.encouragementMessage)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            if let startDate = streak.startDate {
                Text("Started \(DateFormatter.shortDate(from: startDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.yellow.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 32, weight: .bold))

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}
