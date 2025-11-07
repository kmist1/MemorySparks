//
//  UIApplication+Extensions.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/4/25.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
