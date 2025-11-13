//
//  PrivacyPolicyView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                privacySection(
                    icon: "lock.shield.fill",
                    title: "Your Data Stays Local",
                    description: "All your memories and photos are stored only on your device. We never upload your data to any servers."
                )
                
                privacySection(
                    icon: "icloud.slash.fill",
                    title: "No Cloud Sync",
                    description: "Auremi doesn't use iCloud or any cloud services. Your memories remain completely private."
                )
                
                privacySection(
                    icon: "person.slash.fill",
                    title: "No Accounts Required",
                    description: "You don't need to create an account or provide any personal information to use Auremi."
                )
                
                privacySection(
                    icon: "chart.bar.xaxis",
                    title: "No Analytics",
                    description: "We don't track your usage or collect any analytics data. Your privacy is our priority."
                )
                
                privacySection(
                    icon: "arrow.up.doc.fill",
                    title: "Export Anytime",
                    description: "You can export all your data at any time. Your memories belong to you."
                )
                
                privacySection(
                    icon: "trash.fill",
                    title: "Delete Everything",
                    description: "You have full control to delete all your data permanently whenever you choose."
                )
                
                Divider()
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Permissions")
                        .font(.headline)
                    
                    Text("Auremi only requests the following permissions:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    permissionRow(icon: "bell.fill", text: "Notifications - for daily reminders (optional)")
                    permissionRow(icon: "camera.fill", text: "Camera - to capture photos (optional)")
                    permissionRow(icon: "photo.fill", text: "Photo Library - to select photos (optional)")
                }
                
                Text("Last updated: \(DateFormatter.shortDate(from: Date()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func privacySection(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func permissionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.leading, 8)
    }
}
