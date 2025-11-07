//
//  MemoryCardView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI

struct MemoryCardView: View {
    let memory: Memory
    @State private var image: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Photo or Placeholder
            Group {
                if let uiImage = image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else if memory.hasPhoto {
                    ZStack {
                        Color(.systemGray5)
                        ProgressView()
                    }
                } else {
                    // Text-only memory
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color(red: 0.8, green: 0.9, blue: 1.0),
                                Color(red: 0.9, green: 0.8, blue: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        Image(systemName: "text.quote")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Date and preview text
            VStack(alignment: .leading, spacing: 4) {
                Text(DateFormatter.relativeDate(from: memory.date ?? Date()))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                if let text = memory.text, !text.isEmpty {
                    Text(text)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let filename = memory.photoFilename else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let loadedImage = PhotoStorageManager.shared.loadPhoto(filename: filename) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }
    }
}
