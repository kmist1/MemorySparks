//
//  SettingsViewModel.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI
import Combine
import UserNotifications

class SettingsViewModel: ObservableObject {
    @Published var notificationTime = Date()
    @Published var isNotificationsEnabled = false
    @Published var isLockScreenBlurEnabled = true
    @Published var showingExportSheet = false
    @Published var showingDeleteAlert = false
    @Published var exportURL: URL?
    @Published var isExporting = false
    @Published var isDeleting = false
    @Published var errorMessage: String?
    
    private let notificationManager = NotificationManager.shared
    private let privacyManager = PrivacyManager.shared
    private let exportService = ExportService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var totalMemories: Int {
        MemoryManager().getAllMemories().count
    }
    
    var storageSize: String {
        let bytes = PhotoStorageManager.shared.getTotalStorageSize()
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    init() {
        loadSettings()
        checkNotificationStatus()
    }
    
    private func loadSettings() {
        // Load notification time
        let hour = UserDefaults.standard.integer(forKey: "notificationHour")
        let minute = UserDefaults.standard.integer(forKey: "notificationMinute")
        var components = DateComponents()
        components.hour = hour == 0 ? 20 : hour // Default 8 PM
        components.minute = minute
        notificationTime = Calendar.current.date(from: components) ?? Date()
        
        // Load blur setting
        isLockScreenBlurEnabled = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.isLockScreenBlurEnabled)
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func updateNotificationTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        
        UserDefaults.standard.set(components.hour, forKey: "notificationHour")
        UserDefaults.standard.set(components.minute, forKey: "notificationMinute")
        
        if isNotificationsEnabled {
            notificationManager.scheduleDailyNotification(at: components)
        }
    }
    
    func toggleNotifications() {
        if isNotificationsEnabled {
            // User wants to disable - cancel notifications
            notificationManager.cancelAllNotifications()
            isNotificationsEnabled = false
        } else {
            // User wants to enable - request permission
            notificationManager.requestAuthorization { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isNotificationsEnabled = granted
                    if granted {
                        self?.updateNotificationTime()
                    } else {
                        // Open settings
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
    }
    
    func toggleLockScreenBlur() {
        isLockScreenBlurEnabled.toggle()
        UserDefaults.standard.set(isLockScreenBlurEnabled, forKey: AppConstants.UserDefaultsKeys.isLockScreenBlurEnabled)
        privacyManager.setBlurEnabled(isLockScreenBlurEnabled)
    }
    
    func exportAllData() {
        isExporting = true
        errorMessage = nil
        
        exportService.exportAllData { [weak self] result in
            DispatchQueue.main.async {
                self?.isExporting = false
                
                switch result {
                case .success(let url):
                    self?.exportURL = url
                    self?.showingExportSheet = true
                case .failure(let error):
                    self?.errorMessage = "Export failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deleteAllData() {
        isDeleting = true
        errorMessage = nil
        
        let memoryManager = MemoryManager()
        let memories = memoryManager.getAllMemories()
        
        for memory in memories {
            _ = memoryManager.deleteMemory(memory)
        }
        
        // Reset streak
        StreakManager.shared.resetStreak()
        
        // Reset user defaults
        UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaultsKeys.firstEntryDate)
        UserDefaults.standard.removeObject(forKey: "lastEntryDate")
        
        isDeleting = false
        
        // Provide haptic feedback
        HapticsManager.shared.playSuccess()
    }
}
