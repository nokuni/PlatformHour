//
//  SaveManager.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/03/23.
//

import CoreData

class SaveManager {
    
    static var shared = SaveManager()
    
    var container = PersistenceController.shared.container
    
    func fetch<R: NSFetchRequestResult>(_ entityName: String, sorting: [NSSortDescriptor]? = nil) -> [R] {
        let request = NSFetchRequest<R>(entityName: entityName)
        request.sortDescriptors = sorting
        do {
            return try container.viewContext.fetch(request)
        } catch let error {
            print("\(error)")
        }
        return []
    }
    
    func delete(object: NSManagedObject) {
        container.viewContext.delete(object)
        saveData()
    }
    
    func delete(objects: [NSManagedObject]) {
        objects.forEach { container.viewContext.delete($0) }
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
        } catch {
            print("Error saving \(error)")
        }
    }
}
