//
//  StreakBadgeView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//

import SwiftUI

struct StreakBadgeView: View {
    @StateObject private var streakManager = StreakManager.shared
    @State private var showingDetail = false

    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundColor(.orange)

                Text("\(streakManager.currentStreak)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.orange.opacity(0.15))
            )
        }
        .sheet(isPresented: $showingDetail) {
            StreakDetailView()
        }
    }
}
