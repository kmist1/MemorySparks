//
//  WelcomeView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//


import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon or Illustration
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(AppConstants.Colors.primary)
            
            Text("Welcome to MemorySpark")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Capture one smile a day\nin 10 seconds or less")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    viewModel.currentPage = 1
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
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