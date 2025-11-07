//
//  CaptureViewModel.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//


import SwiftUI
import Combine
import PhotosUI

class CaptureViewModel: ObservableObject {
    @Published var entryText: String = ""
    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var showConfetti = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var existingMemory: Memory?

    private let memoryManager: MemoryManager
    private let photoManager = PhotoStorageManager.shared
    private let hapticsManager = HapticsManager.shared
    private let streakManager = StreakManager.shared
    private var cancellables = Set<AnyCancellable>()

    var isEditingExisting: Bool {
        existingMemory != nil
    }

    var canSave: Bool {
        !entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil
    }

    init(memoryManager: MemoryManager = MemoryManager()) {
        self.memoryManager = memoryManager
        loadTodaysMemory()
    }

    func loadTodaysMemory() {
        if let memory = memoryManager.getMemory(for: Date()) {
            loadExistingMemory(memory)
        }
    }

    func loadExistingMemory(_ memory: Memory) {
        existingMemory = memory
        entryText = memory.text ?? ""

        // Load photo if exists
        if let filename = memory.photoFilename {
            selectedImage = photoManager.loadPhoto(filename: filename)
        }
    }

    func saveMemory() {
        guard canSave else { return }

        isLoading = true
        errorMessage = nil

        // Trim text
        let trimmedText = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        let textToSave = trimmedText.isEmpty ? nil : trimmedText

        // Save photo if new one selected
        var photoFilename: String? = existingMemory?.photoFilename
        if let image = selectedImage {
            if let filename = photoManager.savePhoto(image) {
                photoFilename = filename
            } else {
                errorMessage = "Failed to save photo. Please try again."
                isLoading = false
                return
            }
        }

        let result = memoryManager.createMemory(
            date: Date(),
            text: textToSave,
            photoFilename: photoFilename
        )

        switch result {
        case .success:
            // Update streak
            streakManager.updateStreak(for: Date())

            // Trigger success feedback
            hapticsManager.playSuccess()

            withAnimation(.spring()) {
                showConfetti = true
            }

            // Auto-hide confetti after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.showConfetti = false
                }
            }

            isLoading = false

        case .failure(let error):
            errorMessage = "Failed to save memory: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func deletePhoto() {
        selectedImage = nil
        hapticsManager.playLight()
    }

    func clearAll() {
        entryText = ""
        selectedImage = nil
    }
}
