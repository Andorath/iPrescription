//
//  ModelLayerTests.swift
//  iPrescription
//
//  Created by Marco Salafia on 17/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//
@testable import iPrescription
import XCTest
import CoreData

class ModelLayerTests: XCTestCase
{
    var model: PrescriptionList?
    
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext
    {
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do
        {
            try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        } catch _
        {
            
        }
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
    
    override func setUp()
    {
        super.setUp()
        let managedObjectContext = setUpInMemoryManagedObjectContext()
        model = PrescriptionList(context: managedObjectContext)
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testAddPrescriptions()
    {
        model!.addPrescription(Prescription(nome: "1"))
        model!.addPrescription(Prescription(nome: "2"))
        model!.addPrescription(Prescription(nome: "3"))
        
        XCTAssertTrue(model!.numberOfPrescriptions() == 3, "Non sono state aggiunte crrettamente le prescrizioni.")
    }
    
    func testAlreadyExistsPrescription()
    {
        let newPrescription = Prescription(nome: "Nuova")
        model!.addPrescription(newPrescription)
        
        XCTAssertTrue(model!.alreadyExistsPrescription("Nuova"), "Non è stata trovata una prescrizione con lo stesso nome")
    }
    
    func testGetPrescriptionAtIndex()
    {
        model!.addPrescription(Prescription(nome: "1"))
        model!.addPrescription(Prescription(nome: "2"))
        model!.addPrescription(Prescription(nome: "3"))
        
        let pres = model!.getPrescriptionAtIndex(1)
        
        XCTAssertEqual(pres.nome, "2", "La prescrizione all'indice fornito non è quella che si aspettava")
    }
    
    func testNumberOfDrugsForPrescription()
    {
        let prescription = Prescription(nome: "Nuova")
        prescription.medicine = [Drug(name: "Med1"), Drug(name: "Med2"), Drug(name: "Med3")]
        model!.addPrescription(prescription)
        
        XCTAssertTrue(model!.numberOfDrugsForPrescription(prescription) == 3, "Il numero di medicine non corrisponde")
    }
    
    func testNumberOfNotificationForPrescriptionAtIndex()
    {
        let prescription = Prescription(nome: "Nuova")
        let drugOne = Drug(name: "Drug1")
        let drugTwo = Drug(name: "Drug2")
        prescription.medicine = [drugOne, drugTwo]
        model?.addPrescription(prescription)
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 60)
        notification.timeZone = NSTimeZone.defaultTimeZone()
        var userInfo = [String : String]()
        userInfo["id"] = drugOne.id
        notification.userInfo = userInfo
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        let notification2 = UILocalNotification()
        notification2.fireDate = NSDate(timeIntervalSinceNow: 60)
        notification2.timeZone = NSTimeZone.defaultTimeZone()
        userInfo = [String : String]()
        userInfo["id"] = drugTwo.id
        notification2.userInfo = userInfo
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification2)
        
        let numNotif = model?.numberOfNotificationsForPrescriptionAtIndex(0)
        
        XCTAssertTrue(numNotif == 2)
    }
    
    func testModelContainsDrug()
    {
        let prescription = Prescription(nome: "Nuova")
        let checkDrug = Drug(name: "Med3")
        prescription.medicine = [Drug(name: "Med1"), Drug(name: "Med2"), checkDrug]
        model!.addPrescription(prescription)
        
        XCTAssertTrue(model!.modelContainsDrug(checkDrug))
    }
    
    func testDeletePrescriptionAtIndex()
    {
        model!.addPrescription(Prescription(nome: "1"))
        model!.addPrescription(Prescription(nome: "2"))
        model!.addPrescription(Prescription(nome: "3"))
        
        model!.deletePrescriptionAtIndex(1)
        
        XCTAssertFalse(model!.alreadyExistsPrescription("2"))
    }
    
    func testSetNewNameForPrescription()
    {
        let prescription = Prescription(nome: "Prescrizione")
        model!.addPrescription(prescription)
        model!.setNewNameForPrescription(prescription, withNewName: "Claudia")
        
        XCTAssertFalse(model!.alreadyExistsPrescription("Prescrizione"))
        XCTAssertTrue(model!.alreadyExistsPrescription("Claudia"))
    }
    
    func testThereAreNotificationForDrug()
    {
        let prescription = Prescription(nome: "Claudia")
        model!.addPrescription(prescription)
        let drug = Drug(name: "Med")
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 60)
        notification.timeZone = NSTimeZone.defaultTimeZone()
        var userInfo = [String : String]()
        userInfo["id"] = drug.id
        notification.userInfo = userInfo
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        XCTAssertTrue(model!.thereAreNotificationsForDrug(drug))
    }
    
    func testGetDrugAtIndex()
    {
        let prescription = Prescription(nome: "Claudia")
        prescription.medicine = [Drug(name: "Med1"), Drug(name: "Med2"), Drug(name: "Med3")]
        model!.addPrescription(prescription)
        
        let drug = model!.getDrugAtIndex(2, forPrescription: prescription)
        
        XCTAssertTrue(drug.nome == "Med3")
    }
    
    func testUpdateDrug()
    {
        let changingDrug = Drug(name: "Med3")
        let prescription = Prescription(nome: "Claudia")
        prescription.medicine = [Drug(name: "Med1"), Drug(name: "Med2"), changingDrug]
        model!.addPrescription(prescription)
        
        var resultDrug = model!.getDrugAtIndex(2, forPrescription: prescription)
        
        XCTAssertTrue(resultDrug.nome == "Med3")
        
        changingDrug.nome = "NewName"
        model!.updateDrug(changingDrug)
        
        resultDrug = model!.getDrugAtIndex(2, forPrescription: prescription)
        
        XCTAssertTrue(resultDrug.nome == "NewName")
    }
    
    func testGetPrescriptionFromDrug()
    {
        let drug = Drug(name: "Drug")
        let prescription = Prescription(nome: "Claudia")
        prescription.medicine = [drug]
        
        model!.addPrescription(prescription)
        
        let result = model!.getPrescriptionFromDrug(drug)
        
        XCTAssertTrue(result.nome == "Claudia")
    }
    
    func testRightNumberOfPrescription()
    {
        let pres1 = Prescription(nome: "A")
        let drug1 = Drug(name: "1")
        pres1.medicine = [drug1, Drug(name: "2")]
        model!.addPrescription(pres1)
        let pres2 = Prescription(nome: "B")
        pres2.medicine = [Drug(name: "1"), Drug(name: "2")]
        model!.addPrescription(pres2)
        let pres3 = Prescription(nome: "Claudia")
        let drug2 = Drug(name: "2")
        pres3.medicine = [Drug(name: "1"), drug2]
        model!.addPrescription(pres3)
        
        XCTAssertTrue(model!.countPrescriptions() == 3)
        XCTAssertTrue(model!.countDrugs() == 6)
        
        model!.deletePrescriptionAtIndex(0)
        model!.deleteDrugForPrescription(pres3, atIndex: 1)
        
        XCTAssertTrue(model!.countPrescriptions() == 2)
        XCTAssertTrue(model!.countDrugs() == 3)
        
    }
    
}
