// COMMENTO D PROVA REDESIGN
//
//  AppDelegate.swift
//  iPrescription
//
//  Created by Marco on 28/06/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATA

import UIKit
import CoreData
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
                            
    var window: UIWindow?
    var soundManager: SoundManager = SoundManager(resource: "chord", ofType: "m4r")
    var currentController: UIViewController {
        get {
            let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController
            if let topController = rootController as? UINavigationController
            {
                if var topController = topController.topViewController
                {
                    while let presentedViewController = topController.presentedViewController
                    {
                        topController = presentedViewController
                    }
                    
                    return topController
                }
            }
            return rootController!
        }
    }
    lazy var prescriptionsModel: PrescriptionList = PrescriptionList()
    
    //MARK: - Metodi Application Delegate

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        requestNotificationPermissionForApplication(application)        
        resetApplicationIconBadge()

        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        if(application.applicationState == UIApplicationState.Active)
        {
            soundManager.playSound()
            manageNotification(notification)
        }
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication)
    {
        self.saveContext()
    }
    
    //MARK: - Metodi di Gestione
    
    func requestNotificationPermissionForApplication(application: UIApplication)
    {
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound,
                                                                                           UIUserNotificationType.Alert,
                                                                                           UIUserNotificationType.Badge],
                                                                                categories: nil))
    }
    
    func resetApplicationIconBadge()
    {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func manageNotification(notification: UILocalNotification)
    {
        let id = notification.userInfo!["id"] as! String
        let prescriptionName = notification.userInfo!["prescrizione"] as! String
        let prescription = prescriptionsModel.getPrescriptionWithName(prescriptionName)
        let drug = prescriptionsModel.getDrugWithId(id)
        
        let alert = getAlertControllerForDrug(drug, ofPrescription: prescription)
        currentController.presentViewController(alert, animated: true){ alert in
                                                                        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdatePrescriptionInterface", object: nil)
                                                                        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdateDrugsInterface", object: nil)
                                                                        self.resetApplicationIconBadge()
                                                                      }
    }
    
    func getAlertControllerForDrug(drug: Drug, ofPrescription prescription: Prescription) -> UIAlertController
    {
        let alert = UIAlertController(title: drug.nome,
                                      message: String(format: NSLocalizedString("Prescrizione: %@\nMemo: %@",
                                                                                comment: "Messaggio della notifica"),
                                                                                prescription.nome,
                                                                                drug.note),
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Bottone ok notifica"),
                                     style: UIAlertActionStyle.Cancel,
                                     handler: nil))
        
        //TODO: Implementare il Forced Controller Pattern
        
        return alert
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.stain.sattoh" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("iPrescription", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("iPrescription.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        var options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

}

