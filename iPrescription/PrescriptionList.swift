//
//  PrescriptionModel.swift
//  iPrescription
//
//  Created by Marco Salafia on 08/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PrescriptionList
{
    let del: AppDelegate
    let context: NSManagedObjectContext
    
    var prescriptions: [NSManagedObject]?
    
    init()
    {
        del = UIApplication.sharedApplication().delegate as! AppDelegate
        context = del.managedObjectContext!
        updateDataFromModel()
    }
    
    func updateDataFromModel()
    {
        let request = NSFetchRequest(entityName: "Terapia")
        request.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        prescriptions = try! context.executeFetchRequest(request) as? [NSManagedObject]
    }
    
    func numberOfPrescriptions() -> Int
    {
        return prescriptions!.count
    }
    
    func getPrescriptionAtIndex(index: Int) -> Prescription
    {
        let selectedPrecription = prescriptions?[index]
        let nome = selectedPrecription?.valueForKey("nome") as! String
        let creazione = selectedPrecription?.valueForKey("creazione") as! NSDate
        
        return Prescription(nome: nome, creazione: creazione)
    }
    
    func numberOfDrugsForPrescriptionAtIndex(index: Int) -> Int
    {
        let medicineList = (prescriptions![index].valueForKey("medicine") as! NSOrderedSet).array
        return medicineList.count
    }
    
    func numberOfNotificationsForPrescriptionAtIndex(index: Int) -> Int
    {
        var count: Int = 0
        let medicineList = (prescriptions![index].valueForKey("medicine") as! NSOrderedSet).array
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        
        for medicine in medicineList
        {
            let id = (medicine as! NSManagedObject).valueForKey("id") as! String
            
            for notification in notifications!
            {
                if id == notification.userInfo!["id"] as! String
                {
                    count++
                }
            }
        }
        
        return count
    }
    
}
