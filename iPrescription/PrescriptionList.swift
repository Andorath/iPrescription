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
    
    var prescriptions: [Prescription]?
    
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
        
        prescriptions = try! context.executeFetchRequest(request) as? [Prescription]
    }
    
    func numberOfPrescriptions() -> Int
    {
        return prescriptions!.count
    }
    
    func getPrescriptionAtIndex(index: Int) -> Prescription
    {
        return prescriptions![index]
    }
    
    func numberOfDrugsForPrescriptionAtIndex(index: Int) -> Int
    {
        let medicineList = prescriptions![index].medicine
        return medicineList.count
    }
    
    func numberOfNotificationsForPrescriptionAtIndex(index: Int) -> Int
    {
        var count: Int = 0
        let medicineList = prescriptions![index].medicine
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        
        for medicine in medicineList
        {
            let id = medicine.id
            
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
