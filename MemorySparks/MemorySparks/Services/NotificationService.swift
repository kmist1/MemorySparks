//
//  NotificationService.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/4/25.
//


import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func scheduleStreakReminder(streak: Int) {
        guard streak >= 3 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Keep your streak alive! 🔥"
        content.body = "You're on a \(streak) day streak. Don't break it now!"
        content.sound = .default
        
        // Schedule for 9 PM if user hasn't captured today
        var components = DateComponents()
        components.hour = 21
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "streak-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleMilestoneNotification(days: Int) {
        let milestones = [7, 14, 30, 50, 100, 365]
        guard milestones.contains(days) else { return }
        
        let content = UNMutableNotificationContent()
        
        switch days {
        case 7:
            content.title = "One Week Streak! 🎉"
            content.body = "You've captured 7 days in a row. Amazing!"
        case 14:
            content.title = "Two Weeks Strong! 💪"
            content.body = "14 days of memories. Keep it going!"
        case 30:
            content.title = "One Month! 🌟"
            content.body = "30 days of smiles captured. You're building something special."
        case 50:
            content.title = "50 Days! ⚡️"
            content.body = "Half a hundred days! You're unstoppable!"
        case 100:
            content.title = "100 DAYS! 👑"
            content.body = "You're a MemorySpark legend!"
        case 365:
            content.title = "ONE YEAR! 🎊"
            content.body = "365 days of memories. This is incredible!"
        default:
            break
        }
        
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "milestone-\(days)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}