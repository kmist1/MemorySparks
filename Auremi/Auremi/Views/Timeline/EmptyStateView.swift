//
//  EmptyStateView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Memories Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Capture your first smile today")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Image(systemName: "arrow.down")
                .font(.title3)
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.top, 8)
            
            Text("Tap the + button to get started")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
