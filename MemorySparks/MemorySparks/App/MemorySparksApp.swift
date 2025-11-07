//
//  MemorySparksApp.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//

import SwiftUI

@main
struct MemorySparkApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var notificationManager = NotificationManager.shared

    let persistenceController = PersistenceController.shared

    init() {
        // Initialize privacy manager
        _ = PrivacyManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .environmentObject(notificationManager)
                .onAppear {
                    handleAppLaunch()
                }
                .onChange(of: notificationManager.pendingNotificationAction) { action in
                    handleNotificationAction(action)
                }
        }
    }

    private func handleAppLaunch() {
        // Update badge on launch
        notificationManager.updateBadge()

        // Check if launched from notification
        if let action = notificationManager.pendingNotificationAction {
            handleNotificationAction(action)
        }
    }

    private func handleNotificationAction(_ action: NotificationAction?) {
        guard let action = action else { return }

        // Ensure onboarding is complete
        guard appState.hasCompletedOnboarding else { return }

        switch action {
        case .openCapture:
            // Navigate to capture tab
            appState.selectedTab = 1

        case .textInput(let text):
            // This is handled in background, but we can show a success message
            appState.selectedTab = 0 // Show timeline
        }

        // Clear the action
        notificationManager.pendingNotificationAction = nil
    }
}
