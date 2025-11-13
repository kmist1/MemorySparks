//
//  Memory.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/1/25.
//

import Foundation
import CoreData

@objc(Memory)
public class Memory: NSManagedObject {}

extension Memory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memory> {
        NSFetchRequest<Memory>(entityName: "Memory")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var text: String?
    @NSManaged public var photoFilename: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date

    var hasPhoto: Bool {
        guard let photoFilename, !photoFilename.isEmpty else { return false }
        return true
    }

    var hasText: Bool {
        guard let t = text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
        return !t.isEmpty
    }

    var isEmpty: Bool {
        !hasPhoto && !hasText
    }
}
