//
//  OnboardingViewModel.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//


import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var selectedHour = 20 // 8 PM default
    @Published var selectedMinute = 0
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationManager = NotificationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    let totalPages = 3
    
    func requestNotificationPermission() {
        notificationManager.requestAuthorization { [weak self] granted in
            DispatchQueue.main.async {
                self?.notificationPermissionStatus = granted ? .authorized : .denied
                if granted {
                    self?.scheduleNotification()
                }
            }
        }
    }
    
    func scheduleNotification() {
        var components = DateComponents()
        components.hour = selectedHour
        components.minute = selectedMinute
        
        notificationManager.scheduleDailyNotification(at: components)
    }
    
    func completeOnboarding(appState: AppState) {
        // Save notification time
        UserDefaults.standard.set(selectedHour, forKey: "notificationHour")
        UserDefaults.standard.set(selectedMinute, forKey: "notificationMinute")
        
        // Mark onboarding complete
        appState.hasCompletedOnboarding = true
    }
}