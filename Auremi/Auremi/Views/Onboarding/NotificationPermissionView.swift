//
//  NotificationPermissionView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/1/25.
//


import SwiftUI

struct NotificationPermissionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "bell.badge")
                .font(.system(size: 80))
                .foregroundColor(AppConstants.Colors.primary)
            
            Text("Daily Reminder")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Get a gentle nudge at your chosen time to capture today's smile")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Time Picker
            DatePicker("Reminder Time",
                      selection: Binding(
                        get: {
                            var components = DateComponents()
                            components.hour = viewModel.selectedHour
                            components.minute = viewModel.selectedMinute
                            return Calendar.current.date(from: components) ?? Date()
                        },
                        set: { newDate in
                            let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                            viewModel.selectedHour = components.hour ?? 20
                            viewModel.selectedMinute = components.minute ?? 0
                        }
                      ),
                      displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .labelsHidden()
            
            Spacer()
            
            Button(action: {
                viewModel.requestNotificationPermission()
                withAnimation {
                    viewModel.currentPage = 2
                }
            }) {
                Text("Enable Notifications")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppConstants.Colors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                withAnimation {
                    viewModel.currentPage = 2
                }
            }) {
                Text("Skip for Now")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 50)
        }
        .padding()
    }
}
