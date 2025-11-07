//
//  AboutView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // App Icon and Name
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
                    Text("MemorySpark")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Capture one smile a day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                
                // Mission
                VStack(alignment: .leading, spacing: 12) {
                    Text("Our Mission")
                        .font(.headline)
                    
                    Text("MemorySpark helps you capture and preserve life's small joys. One memory at a time, build a collection of moments that made you smile.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    Text("Features")
                        .font(.headline)
                    
                    featureRow(icon: "sparkles", title: "Quick Capture", description: "Save a memory in 10 seconds or less")
                    featureRow(icon: "flame.fill", title: "Streaks", description: "Build a daily habit and track your progress")
                    featureRow(icon: "clock.arrow.circlepath", title: "Flashbacks", description: "Rediscover memories from the past")
                    featureRow(icon: "lock.shield.fill", title: "Privacy First", description: "All data stays on your device")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Contact
                VStack(spacing: 12) {
                    Text("Questions or Feedback?")
                        .font(.headline)
                    
                    Button(action: {
                        if let url = URL(string: "mailto:support@memoryspark.app") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Contact Support", systemImage: "envelope.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Footer
                Text("Made with ❤️ for mindful living")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}