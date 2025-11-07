//
//  TimelineViewModel.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI
import Combine
import CoreData

class TimelineViewModel: ObservableObject {
    @Published var memories: [Memory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedMemory: Memory?
    @Published var showingDetail = false
    @Published var flashbackMemory: Memory?
    @Published var flashback: FlashbackMemory?

    private let flashbackManager = FlashbackManager()
    private let memoryManager: MemoryManager
    private let photoManager = PhotoStorageManager.shared
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    var isEmpty: Bool {
        memories.isEmpty
    }
    
    var totalMemories: Int {
        memories.count
    }
    
    init(memoryManager: MemoryManager = MemoryManager(),
         context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.memoryManager = memoryManager
        self.context = context
        loadMemories()
        checkForFlashback()
    }
    
    func loadMemories() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.memories = self.memoryManager.getAllMemories()
            self.isLoading = false
        }
    }
    
    func deleteMemory(_ memory: Memory) {
        let result = memoryManager.deleteMemory(memory)
        
        switch result {
        case .success:
            // Remove from local array
            memories.removeAll { $0.id == memory.id }
            HapticsManager.shared.playLight()
        case .failure(let error):
            errorMessage = "Failed to delete: \(error.localizedDescription)"
            HapticsManager.shared.playError()
        }
    }
    
    func checkForFlashback() {
        let calendar = Calendar.current
        let today = Date()
        
        // Only show flashbacks after day 7
        guard let firstEntryDate = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.firstEntryDate) as? Date else {
            return
        }
        
        let daysSinceStart = calendar.dateComponents([.day], from: firstEntryDate, to: today).day ?? 0
        guard daysSinceStart >= 7 else { return }
        
        // Find memories from exactly 1 year ago, 1 month ago, or 1 week ago
        let yearsAgo = calendar.date(byAdding: .year, value: -1, to: today)
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today)
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)
        
        // Check in order of priority: year > month > week
        if let date = yearsAgo, let memory = memoryManager.getMemory(for: date) {
            flashbackMemory = memory
        } else if let date = monthAgo, let memory = memoryManager.getMemory(for: date) {
            flashbackMemory = memory
        } else if let date = weekAgo, let memory = memoryManager.getMemory(for: date) {
            flashbackMemory = memory
        }
    }
    
    func selectMemory(_ memory: Memory) {
        selectedMemory = memory
        showingDetail = true
    }
}

extension TimelineViewModel {
    func loadEnhancedFlashbacks() {
        let flashbacks = flashbackManager.findFlashbacks()

        if !flashbacks.isEmpty {
            // Use the most significant flashback (prefer years > months > weeks)
            flashbackMemory = flashbacks.first?.memory
            flashback = flashbacks.first
        } else {
            // Try random flashback
            if let random = flashbackManager.getRandomFlashback() {
                flashbackMemory = random.memory
                flashback = random
            }
        }
    }
}
