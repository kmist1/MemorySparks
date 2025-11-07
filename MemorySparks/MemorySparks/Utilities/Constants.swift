//
//  AppConstants.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//


import SwiftUI

enum AppConstants {
    static let maxTextLength = 500
    static let photosDirectory = "MemoryPhotos"
    static let notificationIdentifier = "dailyMemoryReminder"
    static let thumbnailSize: CGFloat = 150
    
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let notificationTime = "notificationTime"
        static let isNotificationsEnabled = "isNotificationsEnabled"
        static let isLockScreenBlurEnabled = "isLockScreenBlurEnabled"
        static let currentStreak = "currentStreak"
        static let longestStreak = "longestStreak"
        static let firstEntryDate = "firstEntryDate"
    }
    
    enum Colors {
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        static let background = Color("BackgroundColor")
    }
}
