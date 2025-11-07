//
//  Memory.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//


import Foundation
import CoreData

@objc(Memory)
public class Memory: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var text: String?
    @NSManaged public var photoFilename: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date

    convenience init(context: NSManagedObjectContext) {
        self.init(entity: Memory.entity(), insertInto: context)
        self.id = UUID()
        self.date = Date()
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

extension Memory {
    var hasPhoto: Bool {
        photoFilename != nil && !(photoFilename?.isEmpty ?? true)
    }

    var hasText: Bool {
        text != nil && !(text?.isEmpty ?? true)
    }

    var isEmpty: Bool {
        !hasPhoto && !hasText
    }
}
