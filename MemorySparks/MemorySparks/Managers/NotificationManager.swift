//
//  NotificationManager.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//

import UserNotifications
import UIKit

public enum NotificationAction: Equatable {
    case openCapture
    case textInput(String)
}

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var pendingNotificationAction: NotificationAction?

    private let notificationCenter = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    // MARK: - Authorization

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }

            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // MARK: - Scheduling

    func scheduleDailyNotification(at components: DateComponents) {
        // Remove existing notifications
        notificationCenter.removeAllPendingNotificationRequests()

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for today's smile ✨"
        content.body = "Capture your daily memory in just 10 seconds"
        content.sound = .default
        content.categoryIdentifier = "MEMORY_CAPTURE"
        content.badge = 1

        // Add thread identifier for grouping
        content.threadIdentifier = "daily-reminder"

        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Create request
        let request = UNNotificationRequest(
            identifier: AppConstants.notificationIdentifier,
            content: content,
            trigger: trigger
        )

        // Add to notification center
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("✅ Daily notification scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }

        // Set up notification actions
        setupNotificationActions()
    }

    private func setupNotificationActions() {
        // Text input action
        let typeAction = UNTextInputNotificationAction(
            identifier: "TYPE_ACTION",
            title: "Type Memory",
            options: [.authenticationRequired],
            textInputButtonTitle: "Save",
            textInputPlaceholder: "What made you smile today?"
        )

        // Photo action (opens app)
        let photoAction = UNNotificationAction(
            identifier: "PHOTO_ACTION",
            title: "Add Photo",
            options: [.foreground, .authenticationRequired]
        )

        // View action
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View Timeline",
            options: [.foreground]
        )

        // Dismiss action
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Later",
            options: []
        )

        // Create category with actions
        let category = UNNotificationCategory(
            identifier: "MEMORY_CAPTURE",
            actions: [typeAction, photoAction, viewAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([category])
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    // MARK: - Badge Management

        func updateBadge() {
            let memoryManager = MemoryManager()
            let hasToday = memoryManager.hasMemoryForToday()

            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = hasToday ? 0 : 1
            }
        }

        func clearBadge() {
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }

        // MARK: - Testing (Development)

        func scheduleTestNotification(in seconds: TimeInterval = 5) {
            let content = UNMutableNotificationContent()
            content.title = "Test Notification"
            content.body = "This is a test notification"
            content.sound = .default
            content.categoryIdentifier = "MEMORY_CAPTURE"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
            let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)

            notificationCenter.add(request) { error in
                if let error = error {
                    print("Failed to schedule test notification: \(error)")
                } else {
                    print("✅ Test notification scheduled for \(seconds) seconds")
                }
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    extension NotificationManager: UNUserNotificationCenterDelegate {

        // Handle notification when app is in foreground
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            // Show banner even when app is open
            completionHandler([.banner, .sound, .badge])
        }

        // Handle user interaction with notification
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            let actionIdentifier = response.actionIdentifier

            switch actionIdentifier {
            case "TYPE_ACTION":
                // User typed a memory directly from notification
                if let textResponse = response as? UNTextInputNotificationResponse {
                    handleTextInput(text: textResponse.userText)
                }

            case "PHOTO_ACTION":
                // Open app to capture screen with camera
                DispatchQueue.main.async {
                    self.pendingNotificationAction = .openCapture
                }

            case "VIEW_ACTION":
                // Open app to timeline (default behavior)
                break

            case "DISMISS_ACTION":
                // User dismissed - do nothing
                break

            case UNNotificationDefaultActionIdentifier:
                // User tapped the notification itself
                DispatchQueue.main.async {
                    self.pendingNotificationAction = .openCapture
                }

            default:
                break
            }

            completionHandler()
        }

        // MARK: - Action Handlers

        private func handleTextInput(text: String) {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedText.isEmpty else { return }

            // Save memory in background
            let memoryManager = MemoryManager()
            let result = memoryManager.createMemory(date: Date(), text: trimmedText, photoFilename: nil)

            switch result {
            case .success:
                // Update streak
                StreakManager.shared.updateStreak(for: Date())

                // Clear badge
                clearBadge()

                // Show success notification
                scheduleSuccessNotification(text: "Memory saved! 🎉")

                // Send haptic feedback (if app becomes active)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    HapticsManager.shared.playSuccess()
                }

            case .failure(let error):
                print("Failed to save memory from notification: \(error)")
                scheduleErrorNotification()
            }
        }

        private func scheduleSuccessNotification(text: String) {
            let content = UNMutableNotificationContent()
            content.title = text
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "success", content: content, trigger: trigger)

            notificationCenter.add(request)
        }

        private func scheduleErrorNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Failed to save memory"
            content.body = "Please try again"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "error", content: content, trigger: trigger)

            notificationCenter.add(request)
        }
    }

