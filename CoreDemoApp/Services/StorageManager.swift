//
//  StorageManager.swift
//  CoreDemoApp
//
//  Created by Alex Golyshkov on 19.04.2022.
//

import CoreData
import UIKit

enum Action {
    case save
    case delete
    case update
}

class StorageManager {
    //MARK: - Public Properties
    static let shared = StorageManager()
    
    //MARK: - Private Properties
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDemoApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var viewContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    //MARK: - Private Initializer
    private init() {}
    
    //MARK: - Public Methods
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchData() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        do {
            let taskList = try viewContext.fetch(fetchRequest)
            return taskList
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    func performAction(with taskName: String = "", at index: Int = 0, _ action: Action) {
        let tasks = fetchData()
        
        var taskForAction = Task()
        if action != .save { taskForAction = tasks[index] }
        
        switch action {
        case .save:
            let task = Task(context: viewContext)
            print(task)
            task.title = taskName
        case .delete:
            viewContext.delete(taskForAction)
        case .update:
            taskForAction.setValue(taskName, forKey: "title")
        }
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
