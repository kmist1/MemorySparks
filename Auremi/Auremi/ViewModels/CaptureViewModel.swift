//
//  CaptureViewModel.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/1/25.
//

//
//  CaptureViewModel.swift
//  Auremi
//

import Foundation
import SwiftUI
import Combine

final class CaptureViewModel: ObservableObject {
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var showConfetti = false
    @Published var entryText: String = ""
    @Published var selectedImage: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let memoryManager: MemoryManagerProtocol
    private let photoManager: PhotoStorageManager
    private let streakManager: StreakManager
    private let hapticsManager = HapticsManager.shared
    @Published var existingMemory: Memory?

    var isEditingExisting: Bool {
        existingMemory != nil
    }

    init(existingMemory: Memory? = nil,
         memoryManager: MemoryManagerProtocol = MemoryManager(),
         photoManager: PhotoStorageManager = .shared,
         streakManager: StreakManager = .shared) {
        self.existingMemory = existingMemory
        self.memoryManager = memoryManager
        self.photoManager = photoManager
        self.streakManager = streakManager

        if let memory = existingMemory, let photoFilename = memory.photoFilename {
            self.entryText = memory.text ?? ""
            self.selectedImage = photoManager.loadPhoto(filename: photoFilename)
        }

        // If today's memory is being edited, pre-fill text and photo
        if existingMemory == nil, let todayMemory = memoryManager.getMemory(for: Date()) {
            self.existingMemory = todayMemory
            self.entryText = todayMemory.text ?? ""
            self.selectedImage = photoManager.loadPhoto(filename: todayMemory.photoFilename ?? "")
        }
    }

    var canSave: Bool {
        !entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil
    }

    func saveMemory() {
        guard canSave else { return }
        isLoading = true
        errorMessage = nil

        let textToSave = entryText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Handle photo save or removal
        var photoFilename: String?
        if let image = selectedImage {
            if let filename = photoManager.savePhoto(image) {
                photoFilename = filename
            } else {
                errorMessage = "Failed to save photo. Please try again."
                isLoading = false
                return
            }
        } else if existingMemory?.photoFilename != nil {
            // User removed existing photo
            photoFilename = nil
        }

        let result: Result<Memory, Error>

        if let current = existingMemory {
            // Update the current memory
            result = memoryManager.updateMemory(current, text: textToSave, photoFilename: photoFilename)
        } else if let sameDay = memoryManager.getMemory(for: Date()) {
            // Same day already exists → update that one
            result = memoryManager.updateMemory(sameDay, text: textToSave, photoFilename: photoFilename)
            existingMemory = sameDay
        } else {
            // Create a brand new memory
            result = memoryManager.createMemory(date: Date(), text: textToSave, photoFilename: photoFilename)
        }

        switch result {
        case .success(let savedMemory):
            existingMemory = savedMemory
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
            streakManager.updateStreak(for: Date())
        case .failure(let error):
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func getExistingMemory() -> Memory? {
        return existingMemory
    }

    func deletePhoto() {
        selectedImage = nil
    }

    func clearAll() {
        entryText = ""
        selectedImage = nil
    }
}
