//
//  Model.swift
//  iPrescription
//
//  Created by Marco Salafia on 09/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import CoreData

class Prescription : NSManagedObject
{
    @NSManaged var nome: String
    
    @NSManaged var creazione: NSDate
    
    @NSManaged var medicine: [Drug]
}

class Drug : NSManagedObject
{
    @NSManaged var data_ultima_assunzione: NSDate
    
    @NSManaged var dosaggio: String
    
    @NSManaged var dottore: String
    
    @NSManaged var durata: String
    
    @NSManaged var forma: String
    
    @NSManaged var id: String
    
    @NSManaged var nome: String
    
    @NSManaged var note: String
    
}