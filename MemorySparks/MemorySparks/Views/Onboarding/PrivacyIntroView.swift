//
//  PrivacyIntroView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//


import SwiftUI

struct PrivacyIntroView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundColor(AppConstants.Colors.primary)
            
            Text("Your Privacy Matters")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 20) {
                PrivacyFeature(icon: "iphone", text: "All data stays on your device")
                PrivacyFeature(icon: "eye.slash", text: "No accounts or sign-in required")
                PrivacyFeature(icon: "arrow.up.doc", text: "Export your data anytime")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                viewModel.completeOnboarding(appState: appState)
            }) {
                Text("Start Capturing Memories")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppConstants.Colors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .padding()
    }
}

struct PrivacyFeature: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppConstants.Colors.primary)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
    }
}
