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

class PrescriptionModel
{
    let del: AppDelegate
    let context: NSManagedObjectContext
    
    var prescriptions: [NSManagedObject]? = [NSManagedObject]()
    
    init()
    {
        del = UIApplication.sharedApplication().delegate as! AppDelegate
        context = del.managedObjectContext!
        updateDataFromModel()
    }
}
