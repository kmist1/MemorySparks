//
//  PrivacyManager.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//


import UIKit
import SwiftUI

class PrivacyManager {
    static let shared = PrivacyManager()
    
    private var blurView: UIVisualEffectView?
    private var isBlurEnabled: Bool {
        UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.isLockScreenBlurEnabled)
    }
    
    private init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func setBlurEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: AppConstants.UserDefaultsKeys.isLockScreenBlurEnabled)
    }
    
    @objc private func willResignActive() {
        guard isBlurEnabled else { return }
        addBlur()
    }
    
    @objc private func didBecomeActive() {
        removeBlur()
    }
    
    private func addBlur() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = window.bounds
        blurView.tag = 999 // Unique tag to find it later
        
        window.addSubview(blurView)
        self.blurView = blurView
    }
    
    private func removeBlur() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        window.viewWithTag(999)?.removeFromSuperview()
        blurView = nil
    }
}