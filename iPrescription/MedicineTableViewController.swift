//
//  MedicineTableViewController.swift
//  iPrescription
//
//  Created by Marco on 02/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATO

import UIKit
import CoreData

class MedicineTableViewController: UITableViewController {

    var selectedPrescription: String?
    var selectedMedicineName: String?
    var del: AppDelegate
    var context: NSManagedObjectContext
    var medicineList: [AnyObject]

    required init?(coder aDecoder: NSCoder)
    {
        del = UIApplication.sharedApplication().delegate as! AppDelegate
        context = del.managedObjectContext!
        medicineList = [AnyObject]()
        
        super.init(coder: aDecoder)
        
    }
    
    @IBAction func addMedicine(sender: AnyObject)
    {
        let request = NSFetchRequest(entityName: "Terapia")
        let predicate = NSPredicate(format: "nome = %@", selectedPrescription!)
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        
        var results: [AnyObject]?
        do {
            results = try context.executeFetchRequest(request)
        } catch _ {
            results = nil
        }
        let selectedTerapia = (results![0] as! NSManagedObject)
        
        let myVC = storyboard!.instantiateViewControllerWithIdentifier("addFormNavigationController") as! UINavigationController
        (myVC.viewControllers[0] as! AddFormTableViewController).prescription = selectedTerapia
        (myVC.viewControllers[0] as! AddFormTableViewController).newPrescription = false
        self.presentViewController(myVC, animated: true, completion: nil)
    }
    
    //Funzioni Ausiliarie
    
    class func deleteNotificationForMedicine(medicine: NSManagedObject)
    {
        var id = medicine.valueForKey("id") as! NSString
        
        var count =  0
        
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        {
            for notification in notifications
            {
                let userInfo = notification.userInfo
                
                if userInfo!["id"] as! NSString == id
                {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    count++
                }

            }
        }
        
        print("Sono state cancellate \(count) notifiche.")
    }
    
    func thereIsNotificationFor (id: String) -> Bool
    {
        
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        {
            if notifications.count == 0
            {
                return false
            }
            
            for notification in notifications
            {
                if notification.userInfo!["id"] as! String == id
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    override func viewWillAppear(animated: Bool)
    {
        let userInfo = ["currentController" : self]
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Indietro", comment: "BackButton medicine"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
        {
            self.navigationController!.setToolbarHidden(false, animated: false)
        }
        
        tableView.reloadData()
        
        //tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: true)
        let requestMedicina = NSFetchRequest(entityName: "Medicina")
        requestMedicina.returnsObjectsAsFaults = false
        var listMedicina = try! context.executeFetchRequest(requestMedicina) as! [NSManagedObject]
        print("\(listMedicina.count) elementi in Medicina")
        super.viewWillAppear(animated)
    }
    
    func updateInterface ()
    {
        let request = NSFetchRequest(entityName: "Terapia")
        let predicate = NSPredicate(format: "nome = %@", selectedPrescription!)
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        
        var results: [AnyObject]?
        do {
            results = try context.executeFetchRequest(request)
        } catch _ {
            results = nil
        }
        if !results!.isEmpty
        {
            let selectedTerapia = (results![0] as! NSManagedObject)
            medicineList = (selectedTerapia.valueForKey("medicine") as! NSOrderedSet).array
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        
        var viewControllers = self.navigationController!.viewControllers
        let n = viewControllers.count
        
        if n == 1
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let prescriptionController = storyboard.instantiateViewControllerWithIdentifier("prescriptionList") as! PrescriptionTableViewController
            prescriptionController.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Indietro", comment: "BackButton medicine"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.navigationController!.setViewControllers([prescriptionController, self], animated: true)
        }
        
        let request = NSFetchRequest(entityName: "Terapia")
        let predicate = NSPredicate(format: "nome = %@", selectedPrescription!)
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        var results: [AnyObject]?
        do {
            results = try context.executeFetchRequest(request)
        } catch _ {
            results = nil
        }
        let selectedTerapia = (results![0] as! NSManagedObject)
        medicineList = (selectedTerapia.valueForKey("medicine") as! NSOrderedSet).array
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "NSUpdateInterface", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "UIApplicationDidBecomeActiveNotification", object: UIApplication.sharedApplication())
        
        self.navigationItem.title = selectedPrescription
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        
        return medicineList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: MedicineTableViewCell? = tableView.dequeueReusableCellWithIdentifier("my Cell", forIndexPath: indexPath) as? MedicineTableViewCell

        
        let medicina: NSManagedObject = medicineList[indexPath.row] as! NSManagedObject
        cell!.textLabel?.text = medicina.valueForKey("nome") as? String
        
        cell!.imageView?.image = UIImage(named: "Medicine.png")
        
        //inserimento icona allarme
        let id = medicina.valueForKey("id") as! NSString
        if thereIsNotificationFor(id as String)
        {
            cell!.alarmIcon.image = UIImage(named: "alarm_trasparente.png")
        }
        else
        {
            cell!.alarmIcon.image = nil
        }
        
        return cell!

    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        selectedMedicineName = cell!.textLabel?.text
        return indexPath
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
    {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
        {
            self.tableView(tableView, willSelectRowAtIndexPath: indexPath)
            self.performSegueWithIdentifier("toDetail", sender: self)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        
        return true
    }
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            let delObj = medicineList[indexPath!.row] as! NSManagedObject
            
            //Rimuoviamo le notifiche
            MedicineTableViewController.deleteNotificationForMedicine(delObj)
            
            //Rimuoviamo il record dal database
            context.deleteObject(delObj)
            do {
                try context.save()
            } catch _ {
            }
            print("\(medicineList.count) elementi nell'array")
            
            //Probabilmente non è necessario rimuovere  dall'array perchè deleteObject() lo cancella per riferimento
            //UPDATE: dopo Beta 6-7 la riga seguente è necessaria!
            medicineList.removeAtIndex(indexPath!.row)
            tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Right)
            
            //Codice di Diagnostica
            let requestMedicina = NSFetchRequest(entityName: "Medicina")
            var listMedicina = try! context.executeFetchRequest(requestMedicina) as! [NSManagedObject]
            print("\(listMedicina.count) elementi in Medicina")
            
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        {
            let storyboard = UIStoryboard(name: "Main_ipad", bundle: nil)
            let myVC = storyboard.instantiateViewControllerWithIdentifier("IPDetail") as! IPDetailTableViewController
            //let myVC = storyboard.instantiateViewControllerWithIdentifier("detailNavigationController") as UINavigationController
            //NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "MSUpdateDelegate", object: myVC.viewControllers[0]))
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "MSShowDetail", object: myVC))

        }
    }
    
    
    //Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier == "toDetail"
        {
            let destinationController = segue.destinationViewController as! DetailTableViewController
            let request = NSFetchRequest(entityName: "Medicina")
            let predicate = NSPredicate(format: "nome = %@", selectedMedicineName!)
            request.returnsObjectsAsFaults = false
            request.predicate = predicate
            var results: [AnyObject]?
            do {
                results = try context.executeFetchRequest(request)
            } catch _ {
                results = nil
            }
            let selectedMedicina = (results![0] as! NSManagedObject)            
            
            destinationController.selectedMedicine = selectedMedicina
            destinationController.selectedPrescription = selectedPrescription
        }
    }


}
