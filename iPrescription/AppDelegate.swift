// COMMENTO D PROVA REDESIGN
//
//  AppDelegate.swift
//  iPrescription
//
//  Created by Marco on 28/06/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
                            
    var window: UIWindow?
    var soundManager: SoundManager = SoundManager(resource: "chord", ofType: "m4r")
    var currentController: UIViewController
    {
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
    
    var prescriptionsModel: PrescriptionList?
    
    //MARK: - Metodi Application Delegate

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        requestNotificationPermissionForApplication(application)        
        resetApplicationIconBadge()
        registerNotificationActions()
        initDelegate()
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification
        {
            startApplicationFromNotification(notification)
        }

        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        if application.applicationState == UIApplicationState.Active
        {
            manageNotification(notification)
        }
        else
        {
            if application.applicationState == UIApplicationState.Inactive
            {
                dismissAnyPresentedController()
            }
            
            startApplicationFromNotification(notification)
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void)
    {
        if let id = identifier
        {
            switch id
            {
                case "assumptionAction":
                if let drugId = notification.userInfo?["id"] as? String
                {
                    if let drug = prescriptionsModel?.getDrugWithId(drugId)
                    {
                        prescriptionsModel?.setDate(NSDate(), forDrug: drug)
                    }
                }
                case "postponeBy15":
                    notification.posponeNotification(notification, addingTimeInterval: 900)
                case "postponeBy30":
                    notification.posponeNotification(notification, addingTimeInterval: 1800)
                default:
                    print("default")
            }
            
            resetApplicationIconBadge()
            NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdatePrescriptionInterface", object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdateDrugsInterface", object: nil)
        }
        
        completionHandler()
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdatePrescriptionInterface", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdateDrugsInterface", object: nil)
    }

    func applicationWillTerminate(application: UIApplication)
    {
        self.saveContext()
    }
    
    //MARK: - Metodi di Inizializzazione e Gestione Notifiche
    
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
    
    func registerNotificationActions()
    {
        let assumptionAction = UIMutableUserNotificationAction()
        assumptionAction.identifier = "assumptionAction"
        assumptionAction.title = NSLocalizedString("Assumi Ora", comment: "Action notifica Assumi ora")
        assumptionAction.activationMode = .Background
        
        let postponeByFifteenMinutesAction = UIMutableUserNotificationAction()
        postponeByFifteenMinutesAction.identifier = "postponeBy15"
        postponeByFifteenMinutesAction.title = NSLocalizedString("Posticipa di 15 minuti", comment: "Action posticipa notifica 15 minuti")
        postponeByFifteenMinutesAction.activationMode = .Background
        
        let postponeByThirtyMinutesAction = UIMutableUserNotificationAction()
        postponeByThirtyMinutesAction.identifier = "postponeBy30"
        postponeByThirtyMinutesAction.title = NSLocalizedString("Posticipa di 30 minuti", comment: "Action posticipa notifica 30 minuti")
        postponeByFifteenMinutesAction.activationMode = .Background
        
        let postponeCategory = UIMutableUserNotificationCategory()
        postponeCategory.identifier = "postponeCategory"
        postponeCategory.setActions([assumptionAction, postponeByFifteenMinutesAction],
                                    forContext: .Minimal)
        postponeCategory.setActions([assumptionAction, postponeByFifteenMinutesAction, postponeByThirtyMinutesAction],
            forContext: .Default)
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound],
                                                  categories: [postponeCategory])
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func initDelegate()
    {
        prescriptionsModel = PrescriptionList()
    }
    
    func startApplicationFromNotification(notification: UILocalNotification)
    {
        let id = notification.userInfo!["id"] as! String
        let prescriptionName = notification.userInfo!["prescrizione"] as! String
        let memo = notification.userInfo!["memo"] as! String
        let prescription = prescriptionsModel!.getPrescriptionWithName(prescriptionName)
        let drug = prescriptionsModel!.getDrugWithId(id)
        let info = (prescription, drug, memo)
    
        pushControllersHierarchyFromInfo(info)
        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdatePrescriptionInterface", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdateDrugsInterface", object: nil)
    }
    
    func manageNotification(notification: UILocalNotification)
    {
        let alert = getAlertControllerForNotification(notification)
        soundManager.playSound()
        currentController.presentViewController(alert, animated: true){ alert in
                                                                        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdatePrescriptionInterface", object: nil)
                                                                        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdateDrugsInterface", object: nil)
                                                                        self.resetApplicationIconBadge()
                                                                      }
    }
    
    func getAlertControllerForNotification(notification: UILocalNotification) -> UIAlertController
    {
        let id = notification.userInfo!["id"] as! String
        let prescriptionName = notification.userInfo!["prescrizione"] as! String
        let memo = notification.userInfo!["memo"] as! String
        let prescription = prescriptionsModel!.getPrescriptionWithName(prescriptionName)
        let drug = prescriptionsModel!.getDrugWithId(id)
        let info = (prescription, drug, memo)
        
        let alert = UIAlertController(title: drug.nome,
                                      message: String(format: NSLocalizedString("Prescrizione: %@\nMemo: %@",
                                                                                comment: "Messaggio della notifica"),
                                                                                prescription.nome,
                                                                                memo),
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Posticipa di 15 minuti", comment: "Bottone posticipa 15 minuti notifica"),
            style: UIAlertActionStyle.Default){
                alert in
                notification.posponeNotification(notification, addingTimeInterval: 900)
            })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Posticipa di 30 minuti", comment: "Bottone posticipa 30 minuti notifica"),
            style: UIAlertActionStyle.Destructive){
                alert in
                notification.posponeNotification(notification, addingTimeInterval: 1800)
            })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dettaglio", comment: "Bottone dettaglio notifica"),
                                      style: UIAlertActionStyle.Cancel){
                                          alert in
                                          self.dismissAnyPresentedController()
                                          self.pushControllersHierarchyFromInfo(info)
                                      })
        
        return alert
    }
    
    // MARK: - Metodi di Forced Controller
    
    /// Questa funzione è stata implementata in alternativa al pattern Forced Controller adoperato
    /// nella precedente versione di iPrescription (1.0.2).
    /// Questo metodo non costituisce un pattern quindi il codice inerente la forzatura dei controller
    /// è limitata esclusivamente a questa classe.
    /// ---
    /// - note: E' stato necessario passare una tupla (Drug, Prescription) al Detail Controller in modo
    ///        da permettere che questi presenti un messaggio di alert per l'assunzione del farmaco.
    ///        Consultare [DrugDetailViewController](/Users/Marco/Dropbox/Lavoro/iPrescription/iPrescription/DrugDetailController.swift) per notare che:
    ///
    ///       override func viewWillAppear(animated: Bool)
    ///       {
    ///           super.viewWillAppear(animated)
    ///           showAssumptionAlertIfPresent()
    ///           alertInfo = nil
    ///       }
    ///
    /// ---
    /// - parameters:
    ///     - prescription: La prescrizione a cui bisogna fare riferimento per istanziare il
    ///                     DrugTableViewController
    ///     - drug: Il medicinale a cui bisogna fare riferimento per istanziare il DrugDetailController
    
    func pushControllersHierarchyFromInfo(info: (prescription: Prescription, drug: Drug, memo: String))
    {
        if let rootNavigationController = self.window!.rootViewController as? UINavigationController
        {
            let viewControllers = buildControllersHierarchyFromInfo(info)
            
            rootNavigationController.setViewControllers(viewControllers, animated: true)
        }
    }
    
    func dismissAnyPresentedController()
    {
        if let _ = currentController.presentingViewController
        {
            currentController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func buildControllersHierarchyFromInfo(info: (prescription: Prescription, drug: Drug, memo: String)) -> [UIViewController]
    {
        let prescriptionsController = getPrescriptionsController()
        let drugsController = getDrugsControllerForPrescription(info.prescription)
        let detailController = getDetailControllerForDrug(info.drug)
        detailController.alertInfo = info
        
        return [prescriptionsController, drugsController, detailController]
    }
    
    func getPrescriptionsController() -> PrescriptionTableViewController
    {
        if let rootNavigationController = self.window!.rootViewController as? UINavigationController
        {
            if let prescriptionsController = rootNavigationController.viewControllers[0] as? PrescriptionTableViewController
            {
                return prescriptionsController
            }
        }
        
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("prescriptionList") as! PrescriptionTableViewController
    }
    
    func getDrugsControllerForPrescription(prescription: Prescription) -> DrugTableViewController
    {
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        let drugController = storyboard.instantiateViewControllerWithIdentifier("drugList") as! DrugTableViewController
        drugController.setCurrentPrescription(prescription)
        
        return drugController
    }
    
    func getDetailControllerForDrug(drug: Drug) -> DrugDetailController
    {
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        let detailController = storyboard.instantiateViewControllerWithIdentifier("detailViewController") as! DrugDetailController
        detailController.setCurrentDrug(drug)
        
        return detailController
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

