//
//  OnboardingContainerView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/1/25.
//


import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            WelcomeView()
                .tag(0)
            
            NotificationPermissionView(viewModel: viewModel)
                .tag(1)
            
            PrivacyIntroView(viewModel: viewModel)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
