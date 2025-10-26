//
//  CoreDataPerformanceStore.swift
//  PerformanceTracker
//
//  Created by Sergey on 25.10.2025.
//

import CoreData

fileprivate enum Constants {
    static let modelName = "PerformaneTrackerModel"
    static let entityName = "PerformanceEntity"
}

final class CoreDataPerformanceStore: PerformanceStore {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer = CoreDataStack.shared.container) {
        self.container = container
    }

    func fetchAll() async throws -> [Performance] {
        try await withCheckedThrowingContinuation { cont in
            let ctx = container.viewContext
            let req = NSFetchRequest<PerformanceEntity>(entityName: Constants.entityName)
            do {
                let results = try ctx.fetch(req)
                cont.resume(returning: results.map { $0.toPerformance() })
            } catch {
                cont.resume(throwing: error)
            }
        }
    }

    func save(_ performance: Performance) async throws {
        try await withCheckedThrowingContinuation { cont in
            let ctx = container.newBackgroundContext()
            ctx.perform {
                do {
                    let ent = PerformanceEntity(context: ctx)
                    ent.apply(from: performance)
                    try ctx.save()
                    cont.resume(returning: ())
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
}

final class CoreDataStack {
    static let shared = CoreDataStack()
    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = Constants.entityName
        entity.managedObjectClassName = Constants.entityName

        var properties: [NSAttributeDescription] = []

        let idAttr = NSAttributeDescription(); idAttr.name = "id"; idAttr.attributeType = .UUIDAttributeType; idAttr.isOptional = false
        let titleAttr = NSAttributeDescription(); titleAttr.name = "title"; titleAttr.attributeType = .stringAttributeType; titleAttr.isOptional = false
        let locationAttr = NSAttributeDescription(); locationAttr.name = "location"; locationAttr.attributeType = .stringAttributeType; locationAttr.isOptional = false
        let durationAttr = NSAttributeDescription(); durationAttr.name = "durationMinutes"; durationAttr.attributeType = .doubleAttributeType; durationAttr.isOptional = false
        let dateAttr = NSAttributeDescription(); dateAttr.name = "date"; dateAttr.attributeType = .dateAttributeType; dateAttr.isOptional = false
        let storageAttr = NSAttributeDescription(); storageAttr.name = "storage"; storageAttr.attributeType = .stringAttributeType; storageAttr.isOptional = false

        properties.append(contentsOf: [idAttr, titleAttr, locationAttr, durationAttr, dateAttr, storageAttr])
        entity.properties = properties

        model.entities = [entity]

        container = NSPersistentContainer(name: Constants.modelName, managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { desc, error in
            if let error = error {
                fatalError("CoreData failed to load: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

@objc(PerformanceEntity)
final class PerformanceEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var location: String
    @NSManaged var durationMinutes: Double
    @NSManaged var date: Date
    @NSManaged var storage: String
}

extension PerformanceEntity {
    func toPerformance() -> Performance {
        return Performance(id: id, title: title, location: location, durationMinutes: durationMinutes, date: date, storage: StorageType(rawValue: storage) ?? .unknown)
    }

    func apply(from p: Performance) {
        id = p.id
        title = p.title
        location = p.location
        durationMinutes = p.durationMinutes
        date = p.date
        storage = p.storage.rawValue
    }
}
