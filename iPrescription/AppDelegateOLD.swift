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

//@UIApplicationMain
class AppDelegateOLD: UIResponder, UIApplicationDelegate
{
                            
    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?
    var currentController: UIViewController!
    lazy var prescriptionsModel: PrescriptionList = PrescriptionList()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        //richiesta permessi per le notifiche
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound,
                                                                                           UIUserNotificationType.Alert,
                                                                                           UIUserNotificationType.Badge],
                                                                                categories: nil))
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentController:", name: "UpdateCurrentControllerNotification", object: nil)
        
//        print(NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce"))
//        
//        if NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce")
//        {
//            //L'app è stata già lanciata almeno una volta
//            print("E' stata già lanciata")
//        }
    
        
        //gestione delle notifiche locali ricevute
        if let notification: UILocalNotification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification
        {
            let id = notification.userInfo!["id"] as! String
            let prescription = notification.userInfo!["prescrizione"] as! String
            var medicine = notification.userInfo!["medicina"] as! String
            var memo = notification.userInfo!["memo"] as! String
            
            let request = NSFetchRequest(entityName: "Medicina")
            let predicate = NSPredicate(format: "id = %@", id)
            request.returnsObjectsAsFaults = false
            request.predicate = predicate
            
            var results: [AnyObject]?
            do {
                results = try managedObjectContext?.executeFetchRequest(request)
            } catch _ {
                results = nil
            }
            let selectedMedicine = results?[0] as! NSManagedObject
            
            
            //TENTIAMO DI APPLICARE IL FORCED CONTROLLERS
            let rootNavigationController = self.window!.rootViewController as! UINavigationController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewControllerWithIdentifier("detailViewController") as! DetailTableViewController
            detailViewController.selectedPrescription = prescription
            detailViewController.selectedMedicine = selectedMedicine
            detailViewController.userInfo = notification.userInfo
            
            //Forziamo il controller
            rootNavigationController.setViewControllers([UIViewController(), detailViewController], animated: true)
            
        }
        
        //fine gestione notifiche locali
            
        //Inizio gestione Appearance
//        let pageControl = UIPageControl.appearance()
//        pageControl.pageIndicatorTintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 0.4)
//        pageControl.currentPageIndicatorTintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 1)

        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        if(application.applicationState == UIApplicationState.Active)
        {
            //creo il suono
            let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("chord", ofType: "m4r")!)
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
            } catch _ {
                audioPlayer = nil
            }
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
            
            //Gestisco notifica
            let id: String = notification.userInfo!["id"] as! NSString as String
            let prescription: String = notification.userInfo!["prescrizione"] as! NSString as String
            let medicine: String = notification.userInfo!["medicina"] as! NSString as String
            let memo: String = notification.userInfo!["memo"] as! NSString as String
            
            let request = NSFetchRequest(entityName: "Medicina")
            let predicate = NSPredicate(format: "id = %@", id)
            request.returnsObjectsAsFaults = false
            request.predicate = predicate
            
            var results: [AnyObject]?
            do {
                results = try managedObjectContext?.executeFetchRequest(request)
            } catch _ {
                results = nil
            }
            let selectedMedicine = results?[0] as! NSManagedObject
            
            let alert = UIAlertController(title: medicine, message: String(format: NSLocalizedString("Prescrizione: %@\nMemo: %@", comment: "Messaggio della notifica"), prescription, memo), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Bottone ok notifica"), style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dettaglio", comment: "Bottone dettaglio notifica"), style: UIAlertActionStyle.Destructive, handler: { alert in
                
                let rootNavigationController = self.window!.rootViewController as! UINavigationController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let detailViewController = storyboard.instantiateViewControllerWithIdentifier("detailViewController") as! DetailTableViewController
                detailViewController.selectedPrescription = prescription
                detailViewController.selectedMedicine = selectedMedicine
                detailViewController.userInfo = notification.userInfo
                if((self.currentController.presentingViewController) != nil)
                {
                    self.currentController.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                }
            
                rootNavigationController.setViewControllers([UIViewController(), detailViewController], animated: true)
            }))
            
            self.currentController.presentViewController(alert, animated: true, completion: {alert in
                NSNotificationCenter.defaultCenter().postNotificationName("NSUpdateInterface", object: nil)
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0})
            
        }
        else if application.applicationState == UIApplicationState.Background
        {
            NSLog("-----> Ero in Background")
            
        }
        else if application.applicationState == UIApplicationState.Inactive
        {
            NSLog("-----> Ero Inattivo")
            let id: String = notification.userInfo!["id"] as! NSString as String
            let prescription: String = notification.userInfo!["prescrizione"] as! NSString as String
            
            let request = NSFetchRequest(entityName: "Medicina")
            let predicate = NSPredicate(format: "id = %@", id)
            request.returnsObjectsAsFaults = false
            request.predicate = predicate
            
            var results: [AnyObject]?
            do {
                results = try managedObjectContext?.executeFetchRequest(request)
            } catch _ {
                results = nil
            }
            let selectedMedicine = results?[0] as! NSManagedObject
            
            
            //TENTIAMO DI APPLICARE IL FORCED CONTROLLERS
            let rootNavigationController = self.window!.rootViewController as! UINavigationController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewControllerWithIdentifier("detailViewController") as! DetailTableViewController
            detailViewController.selectedPrescription = prescription
            detailViewController.selectedMedicine = selectedMedicine
            detailViewController.userInfo = notification.userInfo
            if((self.currentController.presentingViewController) != nil)
            {
                self.currentController.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            }

            rootNavigationController.setViewControllers([UIViewController(), detailViewController], animated: true)
        }
        
    }
    
    //Handler
    
    func updateCurrentController (notification: NSNotification)
    {
        if let vc = notification.userInfo?["currentController"] as? UIViewController
        {
            self.currentController = vc
            
            //Codice di diagnostica
            //println(self.currentController.description)
        }
    }

    func applicationWillResignActive(application: UIApplication)
    {
        
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "NSUpdateInterface", object: nil))
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
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
