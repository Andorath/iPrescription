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
        let managedPresc = prescriptions![index]
        let name = managedPresc.valueForKey("nome") as! String
        let creation = managedPresc.valueForKey("creazione") as! NSDate
        let medicineManaged = (managedPresc.valueForKey("medicine") as! NSOrderedSet).array as! [NSManagedObject]
        let medicine = getDrugsFromManagedDrugs(medicineManaged)
        let prescription = Prescription(nome: name, creazione: creation, drugs: medicine)
        return prescription
    }
    
    func getDrugsFromManagedDrugs(managedDrugs: [NSManagedObject]) -> [Drug]
    {
        var drugs = [Drug]()
        
        for manaDrug in managedDrugs
        {
            let nome = manaDrug.valueForKey("nome") as! String
            let forma = manaDrug.valueForKey("forma") as! String
            let dosaggio = manaDrug.valueForKey("dosaggio") as! String
            let durata = manaDrug.valueForKey("durata") as! String
            let note = manaDrug.valueForKey("note") as! String
            let dottore = manaDrug.valueForKey("dottore") as! String
            let id = manaDrug.valueForKey("id") as! String
            let data_ultima_assunzione = manaDrug.valueForKey("data_ultima_assunzione") as? NSDate
            
            let drug = Drug(name: nome,
                            dosage: dosaggio,
                            doc: dottore,
                            period: durata,
                            form: forma,
                            note: note,
                            id: id,
                            date_last_assumption: data_ultima_assunzione)
            
            drugs.append(drug)
        }
        
        return drugs
    }
    
    func numberOfDrugsForPrescriptionAtIndex(index: Int) -> Int
    {
        let prescription = prescriptions![index]
        let medicineList = (prescription.valueForKey("medicine") as! NSOrderedSet).array
        return medicineList.count
    }
    
    func numberOfNotificationsForPrescriptionAtIndex(index: Int) -> Int
    {
        var count: Int = 0
        let prescription = prescriptions![index]
        let medicineList = (prescription.valueForKey("medicine") as! NSOrderedSet).array
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
    
    func alreadyExistsPrescription(prescriptionName: String) -> Bool
    {
        let request = NSFetchRequest(entityName: "Terapia")
        request.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "nome = %@", prescriptionName)
        request.predicate = predicate
        var results: [AnyObject]?
        do
        {
            results = try context.executeFetchRequest(request)
        }
        catch _
        {
            results = nil
        }
        
        return !results!.isEmpty
    }
    
    func addPrescription(pres: Prescription)
    {
        let prescription = NSEntityDescription.insertNewObjectForEntityForName("Terapia", inManagedObjectContext: context)
        prescription.setValue(pres.nome, forKey: "nome")
        prescription.setValue(pres.creazione, forKey: "creazione")
        
        let drugsSet = getManagedDrugsFromDrugs(pres.medicine)
        prescription.setValue(drugsSet, forKey: "medicine")
        
        do
        {
            try context.save()
        }
        catch _
        {
            
        }
        
        updateDataFromModel()
        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdateInterface", object: nil)
    }
    
    func getManagedDrugsFromDrugs(drugs: [Drug]) -> NSOrderedSet
    {
        let managedDrugs = NSMutableOrderedSet()

        for drug in drugs
        {
            let managedDrug = NSEntityDescription.insertNewObjectForEntityForName("Medicina", inManagedObjectContext: context)
            
            managedDrug.setValue(drug.nome, forKey: "nome")
            managedDrug.setValue(drug.forma, forKey: "forma")
            managedDrug.setValue(drug.durata, forKey: "durata")
            managedDrug.setValue(drug.dosaggio, forKey: "dosaggio")
            managedDrug.setValue(drug.dottore, forKey: "dottore")
            managedDrug.setValue(drug.note, forKey: "note")
            managedDrug.setValue(drug.id, forKey: "id")
            managedDrug.setValue(drug.data_ultima_assunzione, forKey: "data_ultima_assunzione")
            
            managedDrugs.addObject(managedDrug)
        }
        
        return managedDrugs
    }
    
    func deletePrescriptionAtIndex(index: Int)
    {
        let prescription = prescriptions![index]
        let medicine = (prescription.valueForKey("medicine") as! NSOrderedSet).array as! [NSManagedObject]
        deleteNotificationsForDrugs(medicine)
        context.deleteObject(prescription)
        do
        {
            try context.save()
        }
        catch _
        {
        }
        
        updateDataFromModel()
    }
    
    func deleteNotificationsForDrugs(drugs: [NSManagedObject])
    {
        for drug in drugs
        {
            let id = drug.valueForKey("id") as! String
            
            if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
            {
                for notification in notifications
                {
                    let userInfo = notification.userInfo
                    
                    if userInfo!["id"] as! String == id
                    {
                        UIApplication.sharedApplication().cancelLocalNotification(notification)
                    }
                    
                }
            }
        }
    }
    
    func setNewNameForPrescription(prescription: Prescription, withNewName newName: String)
    {
        let editingPrescription = getManagedPrescriptionFromPrescription(prescription)
        editingPrescription.setValue(newName, forKey: "nome")
        do
        {
            try context.save()
        }
        catch _
        {
            
        }
        
        updateDataFromModel()
        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdateInterface", object: nil)
    }
    
    func getManagedPrescriptionFromPrescription(prescription: Prescription) -> NSManagedObject
    {
        let prescriptionName = prescription.nome
        let request = NSFetchRequest(entityName: "Terapia")
        request.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "nome = %@", prescriptionName)
        request.predicate = predicate
        var results: [NSManagedObject]?
        do
        {
            results = try context.executeFetchRequest(request) as? [NSManagedObject]
        }
        catch _
        {
        }
        
        return results![0]
    }
    
}
