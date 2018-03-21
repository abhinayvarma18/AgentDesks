//
//  ADDatabaseHandler.swift
//  AgentdesksTask
//
//  Created by ABHINAY on 20/03/18.
//  Copyright © 2018 ABHINAY. All rights reserved.
//

import UIKit
import CoreData

class ADDatabaseHandler: NSObject {
    static let sharedInstance = ADDatabaseHandler()
    open lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application.
        let modelURL = Bundle.main.url(forResource: "AgentdesksTask", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    open lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("AgentdesksTask.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: url, options: nil)
        } catch {
            // Report any error we got.
            abort()
        }
        
        return coordinator
    }()
    
    open lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    func resetAllRecords() // entity = Your_Entity_Name
    {
        //  let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticleDB")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedObjectContext!.execute(deleteRequest)
            try managedObjectContext!.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    
    func fetchArticlesFromDB() -> [ArticleDB]? {
        let fetchRequest = NSFetchRequest<ArticleDB>(entityName: "ArticleDB")
        do {
            let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
            if fetchedResults.count > 0 {
                return fetchedResults
            }else{
                return nil
            }
        } catch _ as NSError {
            // something went wrong, print the error.
            return nil
        }
    }
    
    func saveArticlesInLocalDB(articles:[Article],pulltorefresh:Bool) {
        if(pulltorefresh) {
            self.resetAllRecords()
        }
        let entity =  NSEntityDescription.entity(forEntityName: "ArticleDB", in:managedObjectContext!)
        for article in articles {
            let articleDB = NSManagedObject(entity: entity!, insertInto:managedObjectContext!)
            articleDB.setValue(article.title, forKey: "title")
            articleDB.setValue(article.desc, forKey: "desc")
            articleDB.setValue(article.url, forKey: "url")
            articleDB.setValue(article.urlToImage, forKey: "urlToImage")
            do {
                try managedObjectContext!.save()
            } catch {
                print("Something went wrong.")
            }
        }
    }
    
}
