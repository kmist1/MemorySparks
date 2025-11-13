//
//  FlashbackBannerView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/3/25.
//

import SwiftUI

struct FlashbackBannerView: View {
    let flashback: FlashbackMemory
    let onTap: () -> Void

    @State private var image: UIImage?

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(flashback.timePeriod.emoji)
                        .font(.title2)

                    Text("On This Day")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    // Thumbnail
                    Group {
                        if let uiImage = image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else if flashback.memory.hasPhoto {
                            ZStack {
                                Color(.systemGray5)
                                ProgressView()
                                    .scaleEffect(0.7)
                            }
                        } else {
                            ZStack {
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.3), Color.orange.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                Image(systemName: "sparkles")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Text preview
                    VStack(alignment: .leading, spacing: 4) {
                        Text(flashback.timePeriod.description)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)

                        if let text = flashback.memory.text, !text.isEmpty {
                            Text(text)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }

                        Text(DateFormatter.shortDate(from: flashback.memory.date ?? Date()))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.1),
                                Color.orange.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.3), Color.orange.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        guard let filename = flashback.memory.photoFilename else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            if let loadedImage = PhotoStorageManager.shared.loadPhoto(filename: filename) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }
    }
}
