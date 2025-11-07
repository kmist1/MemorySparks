//
//  SettingsView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // Notifications Section
                Section {
                    Toggle("Daily Reminder", isOn: $viewModel.isNotificationsEnabled)
                        .onChange(of: viewModel.isNotificationsEnabled) { _ in
                            viewModel.toggleNotifications()
                        }
                    
                    if viewModel.isNotificationsEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $viewModel.notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: viewModel.notificationTime) { _ in
                            viewModel.updateNotificationTime()
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get a daily reminder to capture your memory")
                }
                
                // Privacy Section
                Section {
                    Toggle("Blur in App Switcher", isOn: $viewModel.isLockScreenBlurEnabled)
                        .onChange(of: viewModel.isLockScreenBlurEnabled) { _ in
                            viewModel.toggleLockScreenBlur()
                        }
                    
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("Hide your memories when viewing recent apps")
                }
                
                // Data Section
                Section {
                    HStack {
                        Text("Total Memories")
                        Spacer()
                        Text("\(viewModel.totalMemories)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Storage Used")
                        Spacer()
                        Text(viewModel.storageSize)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        viewModel.exportAllData()
                    }) {
                        HStack {
                            Label("Export All Data", systemImage: "square.and.arrow.up")
                            if viewModel.isExporting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.totalMemories == 0 || viewModel.isExporting)
                    
                    Button(role: .destructive, action: {
                        viewModel.showingDeleteAlert = true
                    }) {
                        Label("Delete All Data", systemImage: "trash")
                    }
                    .disabled(viewModel.totalMemories == 0 || viewModel.isDeleting)
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("Export creates a ZIP file with all your memories and photos")
                }
                
                // About Section
                Section {
                    NavigationLink("About MemorySpark") {
                        AboutView()
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $viewModel.showingExportSheet) {
                if let url = viewModel.exportURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("Delete All Data?", isPresented: $viewModel.showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Everything", role: .destructive) {
                    viewModel.deleteAllData()
                }
            } message: {
                Text("This will permanently delete all your memories and photos. This action cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: { message in
                Text(message)
            }
        }
    }
}
