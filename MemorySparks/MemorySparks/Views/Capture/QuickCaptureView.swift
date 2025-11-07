//
//  QuickCaptureView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/4/25.
//


import SwiftUI

struct QuickCaptureView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CaptureViewModel()
    
    let fromNotification: Bool
    
    var body: some View {
        NavigationView {
            CaptureView()
                .navigationTitle(fromNotification ? "Quick Capture" : "Today's Memory")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}