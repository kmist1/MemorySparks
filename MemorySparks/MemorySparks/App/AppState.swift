//
//  AppState.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }

    @Published var selectedTab: Int = 0
    @Published var shouldShowCapture: Bool = false

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}
