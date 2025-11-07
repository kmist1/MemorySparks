//
//  MemoryManagerProtocol.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//

import Foundation
import CoreData
import Combine

protocol MemoryManagerProtocol {
    func createMemory(date: Date, text: String?, photoFilename: String?) -> Result<Memory, Error>
    func updateMemory(_ memory: Memory, text: String?, photoFilename: String?) -> Result<Memory, Error>
    func deleteMemory(_ memory: Memory) -> Result<Void, Error>
    func getMemory(for date: Date) -> Memory?
    func getAllMemories() -> [Memory]
    func hasMemoryForToday() -> Bool
}

class MemoryManager: MemoryManagerProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func createMemory(date: Date, text: String?, photoFilename: String?) -> Result<Memory, Error> {
        // Check if memory already exists for this date
        if let existing = getMemory(for: date) {
            return updateMemory(existing, text: text, photoFilename: photoFilename)
        }

        let memory = Memory(context: context)
        memory.id = UUID()
        memory.date = Calendar.current.startOfDay(for: date)
        memory.text = text
        memory.photoFilename = photoFilename
        memory.createdAt = Date()
        memory.modifiedAt = Date()

        do {
            try context.save()
            return .success(memory)
        } catch {
            return .failure(error)
        }
    }

    func updateMemory(_ memory: Memory, text: String?, photoFilename: String?) -> Result<Memory, Error> {
        memory.text = text
        if let filename = photoFilename {
            memory.photoFilename = filename
        }
        memory.modifiedAt = Date()

        do {
            try context.save()
            return .success(memory)
        } catch {
            return .failure(error)
        }
    }

    func deleteMemory(_ memory: Memory) -> Result<Void, Error> {
        // Delete associated photo if exists
        if let filename = memory.photoFilename {
            let result = PhotoStorageManager.shared.deletePhoto(filename: filename)
        }

        context.delete(memory)

        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func getMemory(for date: Date) -> Memory? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let request = NSFetchRequest<Memory>(entityName: "Memory")
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    func getAllMemories() -> [Memory] {
        let request = NSFetchRequest<Memory>(entityName: "Memory")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        return (try? context.fetch(request)) ?? []
    }

    func hasMemoryForToday() -> Bool {
        return getMemory(for: Date()) != nil
    }
}
