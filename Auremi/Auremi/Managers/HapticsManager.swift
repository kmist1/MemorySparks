//
//  HapticsManager.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/1/25.
//

import UIKit

class HapticsManager {
    static let shared = HapticsManager()

    private init() {}

    func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func playError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    func playWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    func playLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func playMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func playHeavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}
