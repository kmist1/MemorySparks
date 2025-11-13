//
//  ContentView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/1/25.
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingContainerView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            TimelineView()
                .tabItem {
                    Label("Memories", systemImage: "sparkles")
                }
                .tag(0)
            
            CaptureView()
                .tabItem {
                    Label("Today", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}
