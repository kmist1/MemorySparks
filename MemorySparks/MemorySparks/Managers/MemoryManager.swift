//
//  MemoryManagerProtocol.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//

import Foundation
import CoreData
import UIKit

protocol MemoryManagerProtocol {
    func createMemory(date: Date, text: String?, photoFilename: String?) -> Result<Memory, Error>
    func updateMemory(_ memory: Memory, text: String?, photoFilename: String?) -> Result<Memory, Error>
    func deleteMemory(_ memory: Memory) -> Result<Void, Error>
    func getMemory(for date: Date) -> Memory?
    func getAllMemories() -> [Memory]
    func hasMemoryForToday() -> Bool
}

final class MemoryManager: MemoryManagerProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    // MARK: - Create

    func createMemory(date: Date, text: String?, photoFilename: String?) -> Result<Memory, Error> {
        // If memory already exists for this calendar day, treat as update instead of duplicate
        if let existing = getMemory(for: date) {
            return updateMemory(existing,
                                text: text?.trimmingCharacters(in: .whitespacesAndNewlines),
                                photoFilename: photoFilename)
        }

        let memory = Memory(context: context)
        memory.id = UUID()
        memory.date = date
        memory.text = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        memory.photoFilename = photoFilename
        let now = Date()
        memory.createdAt = now
        memory.modifiedAt = now

        do {
            try context.save()
            return .success(memory)
        } catch {
            context.rollback()
            return .failure(error)
        }
    }

    // MARK: - Update

    func updateMemory(_ memory: Memory, text: String?, photoFilename: String?) -> Result<Memory, Error> {
        let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        memory.text = (trimmed?.isEmpty == true) ? nil : trimmed

        let oldFilename = memory.photoFilename
        let newFilename = (photoFilename?.isEmpty == true) ? nil : photoFilename

        if newFilename == nil {
            // Explicit removal requested
            if let old = oldFilename {
                _ = PhotoStorageManager.shared.deletePhoto(filename: old)
            }
            memory.photoFilename = nil
        } else if newFilename != oldFilename {
            // Replace photo file
            if let old = oldFilename, old != newFilename {
                _ = PhotoStorageManager.shared.deletePhoto(filename: old)
            }
            memory.photoFilename = newFilename
        }

        memory.modifiedAt = Date()

        do {
            try context.save()
            return .success(memory)
        } catch {
            context.rollback()
            return .failure(error)
        }
    }

    // MARK: - Delete

    func deleteMemory(_ memory: Memory) -> Result<Void, Error> {
        if let fname = memory.photoFilename {
            _ = PhotoStorageManager.shared.deletePhoto(filename: fname)
        }
        context.delete(memory)
        do {
            try context.save()
            return .success(())
        } catch {
            context.rollback()
            return .failure(error)
        }
    }

    // MARK: - Fetch

    func getMemory(for date: Date) -> Memory? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return nil }

        let request: NSFetchRequest<Memory> = Memory.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    func getAllMemories() -> [Memory] {
        let request: NSFetchRequest<Memory> = Memory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func hasMemoryForToday() -> Bool {
        getMemory(for: Date()) != nil
    }
}
