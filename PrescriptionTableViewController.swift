//
//  PrescriptionTableViewController.swift
//  iPrescription
//
//  Created by Marco on 15/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATO

import UIKit
import CoreData

class PrescriptionTableViewController: UITableViewController, UITextFieldDelegate {

    var del: AppDelegate
    var context: NSManagedObjectContext
    var therapyList: [AnyObject]
    var selectedRow: String?
    
    var AddAlertSaveAction: UIAlertAction?
    
    required init(coder aDecoder: NSCoder)
    {
        del = UIApplication.sharedApplication().delegate as AppDelegate
        context = del.managedObjectContext!
        therapyList = [AnyObject]()
        
        var request = NSFetchRequest(entityName: "Terapia")
        request.returnsObjectsAsFaults = false
        var sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        therapyList = context.executeFetchRequest(request, error: nil)!
        
        super.init(coder: aDecoder)
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    @IBAction func addTherapy(sender: AnyObject)
    {
        
        let addAlertView = UIAlertController(title: NSLocalizedString("Nuova Prescrizione", comment: "Titolo popup creazione prescrizione"), message: NSLocalizedString("Inserisci un nome per questa prescrizione", comment: "Messaggio popup creazione nuova prescrizione"), preferredStyle: UIAlertControllerStyle.Alert)
        
        addAlertView.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = NSLocalizedString("es: Terapia Antibiotica", comment: "Placeholder popup creazione nuova prescrizione")
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.delegate = self
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:",    name: UITextFieldTextDidChangeNotification, object: textField)})
        
        func removeTextFieldObserver()
        {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: addAlertView.textFields![0])
        }
        
        
        let addAction = UIAlertAction(title: NSLocalizedString("Salva", comment: "Azione salva popup creazione nuova prescrizione"), style: UIAlertActionStyle.Default, handler: { alert in
            
            var stringNoSpaces: NSString = ((addAlertView.textFields![0] as UITextField).text as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if self.alreadyExists(stringNoSpaces)
            {
                let alreadyExistAlert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup errore nome prescrizione"), message: NSLocalizedString("Esiste già una prescrizione con questo nome", comment: "Messaggio popup errore prescrizione"), preferredStyle: UIAlertControllerStyle.Alert)
                alreadyExistAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok popup errore creazione prescrizione"), style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alreadyExistAlert, animated: true, completion: nil)
            }
            else
            {
                
                var prescription = NSEntityDescription.insertNewObjectForEntityForName("Terapia", inManagedObjectContext: self.context) as NSManagedObject
                
                prescription.setValue(stringNoSpaces, forKey: "nome")
                prescription.setValue(NSDate(), forKey: "creazione")
                
                //Fa apparire il View Controller isolato nella storyboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewControllerWithIdentifier("addFormNavigationController") as UINavigationController
                (myVC.viewControllers[0] as AddFormTableViewController).prescription = prescription
                self.presentViewController(myVC, animated: true, completion: nil)
                
                //removeTextFieldObserver()
            }
            
            })
        
        addAction.enabled = false
        
        AddAlertSaveAction = addAction
        
        addAlertView.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: "Annulla popup creazione nuova prescrizione"),
            style: UIAlertActionStyle.Default,
            handler: nil /*{action in removeTextFieldObserver()}*/))
        
        addAlertView.addAction(addAction)
        
        if self.editing
        {
            setEditing(false, animated: true)
        }
        
        self.presentViewController(addAlertView, animated: true, completion: nil)
        
        
    }
    
    //handler
    func handleTextFieldTextDidChangeNotification (notification: NSNotification)
    {
        var textField = notification.object as UITextField
        AddAlertSaveAction!.enabled = textField.text.utf16Count >= 1
    }
    
    func updateInterface ()
    {
        var requestTerapia = NSFetchRequest(entityName: "Terapia")
        var sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        requestTerapia.sortDescriptors = [sortDescriptor]
        therapyList = context.executeFetchRequest(requestTerapia, error: nil)!
        tableView.reloadData()
    }
    
    func alreadyExists (name: String) -> Bool
    {
        var request = NSFetchRequest(entityName: "Terapia")
        request.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "nome = %@", name)
        request.predicate = predicate
        var results = context.executeFetchRequest(request, error: nil)
        
        return !results!.isEmpty
    }
    
    func countNotification(prescription: NSManagedObject) -> Int
    {
        var count: Int = 0
        var medicineList = (prescription.valueForKey("medicine") as NSOrderedSet).array
        var notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        
        for medicine in medicineList
        {
            var id = (medicine as NSManagedObject).valueForKey("id") as NSString
            
            for notification in notifications
            {
                if id == (notification as UILocalNotification).userInfo!["id"] as NSString
                {
                    count++
                }
            }
        }
        
        return count
    }
    
    //Funzioni di modifica
    
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
        
        if editing == true
        {
            self.navigationItem.rightBarButtonItem!.title = NSLocalizedString("Fine", comment: "Edit Button delle prescrizione, da tradurre in inglese con Done")
        }
        else
        {
            self.navigationItem.rightBarButtonItem!.title = NSLocalizedString("Modifica", comment: "Edit Button delle prescrizioni d atradurre in inglese con Edit")
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            var delObj = therapyList[indexPath.row] as NSManagedObject
            
            //Rimuoviamo le notifiche
            var medicineList = (delObj.valueForKey("medicine") as NSOrderedSet).array
            
            for medicina in medicineList
            {
                MedicineTableViewController.deleteNotificationForMedicine(medicina as NSManagedObject)
            }
            
            
            //Rimuoviamo il record dal database
            context.deleteObject(delObj)
            context.save(nil)
            
            //Rimuovimao dal TherapyList
            therapyList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath), withRowAnimation: UITableViewRowAnimation.Right)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if therapyList.count == 0
        {
            self.editing = false
            self.navigationItem.rightBarButtonItem!.title = NSLocalizedString("Modifica", comment: "Edit Button delle prescrizioni d atradurre in inglese con Edit")
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
        else
        {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        
        return therapyList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: PrescriptionTableViewCell? = tableView.dequeueReusableCellWithIdentifier("my Cell") as? PrescriptionTableViewCell
        
        if cell == nil
        {
            cell = PrescriptionTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "my Cell")
        }
        
        var terapia: NSManagedObject = therapyList[indexPath.row] as NSManagedObject
        cell!.textLabel.text = terapia.valueForKey("nome") as? String
        
        cell!.imageView.image = UIImage(named: "Prescription.png")
        var medicineList = (terapia.valueForKey("medicine") as NSOrderedSet).array
        var medString: String
        if medicineList.count == 1
        {
            medString = NSLocalizedString("Medicina", comment: "Sottotitolo riga della prescrizione al singolare")
        }
        else
        {
            medString = NSLocalizedString("Medicine", comment: "Sottotitolo riga della prescrizione al plurale")
        }
        
        var count = countNotification(therapyList[indexPath.row] as NSManagedObject)
        
        if count == 0
        {
            cell!.detailTextLabel!.text = "\(medicineList.count) " + medString
        }
        else if count == 1
        {
            cell!.detailTextLabel!.text = "\(medicineList.count) " + medString +
            String(format: NSLocalizedString(" - %d Notifica", comment: "sottotitolo prescrizione per le notifiche al singolare"), count)
        }
        else
        {
            cell!.detailTextLabel!.text = "\(medicineList.count) " + medString + String(format: NSLocalizedString(" - %d Notifiche", comment: "sottotitolo prescrizione per le notifiche al plurale"), count)
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        selectedRow = cell!.textLabel.text
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if self.editing
        {
            var alertChange = UIAlertController(title: NSLocalizedString("Modifica nome della prescrizione", comment: "Titolo popup modifica nome prescrizione"), message: NSLocalizedString("", comment: "Messaggio vuoto popup modifica nome prescrizione"), preferredStyle: UIAlertControllerStyle.Alert)
            alertChange.addTextFieldWithConfigurationHandler({textField in
                textField.text = self.selectedRow
                textField.delegate = self
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:",    name: UITextFieldTextDidChangeNotification, object: textField)})
            
            func removeTextFieldObserver()
            {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: alertChange.textFields![0])
            }
            
            let changeAction = UIAlertAction(title: NSLocalizedString("Cambia", comment: "comando Cambia popup cambiamento nome prescrizione"), style: UIAlertActionStyle.Default, handler: { alert in
                
                var stringNoSpaces: NSString = ((alertChange.textFields![0] as UITextField).text as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                if self.alreadyExists(stringNoSpaces)
                {
                    let alreadyExistAlert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup errore nome prescrizione"), message: NSLocalizedString("Esiste già una prescrizione con questo nome", comment: "Messaggio popup errore prescrizione"), preferredStyle: UIAlertControllerStyle.Alert)
                    alreadyExistAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok popup errore creazione prescrizione"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alreadyExistAlert, animated: true, completion: nil)
                }
                else
                {
                    
                    var selected = self.therapyList[self.tableView.indexPathForSelectedRow()!.row] as NSManagedObject
                    selected.setValue((alertChange.textFields![0] as UITextField).text, forKey: "nome")
                    self.context.save(nil)
                    
                    var cell = tableView.cellForRowAtIndexPath(indexPath)
                    cell!.textLabel.text = (alertChange.textFields![0] as UITextField).text
                    
                    self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: true)
                    //removeTextFieldObserver()
                }
                
                
                
                })
            
            
            AddAlertSaveAction = changeAction
            
            alertChange.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: "Annulla in popup modifica nome prescrizione"),
                style: UIAlertActionStyle.Default,
                handler: {action in
                    
                    self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: true)
                    /*removeTextFieldObserver()*/}))
            
            alertChange.addAction(changeAction)
            
            self.presentViewController(alertChange, animated: true, completion: nil)
        }
        
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        if tableView.editing
        {
            return UITableViewCellEditingStyle.Delete
        }
        
        return UITableViewCellEditingStyle.None
    }
    
    //Funzioni delegato di testo
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //Segues
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool
    {
        if self.editing == true
        {
            return false
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier == "toMedicines2"
        {
            var destinationController = segue.destinationViewController as MedicineTableViewController
            destinationController.selectedPrescription = selectedRow!
            //cambio back button
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Indietro", comment: "Back button prescrizioni"), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        //tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: true)
        NSNotificationCenter.defaultCenter().postNotificationName("NSUpdateInterface", object: nil)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Indietro", comment: "Back button prescrizioni"), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
        {
            self.navigationController!.setToolbarHidden(false, animated: false)
        }
        var userInfo = ["currentController" : self]
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        
        //Azione del primo avvio (che brutta cosa che c'è sritta sotto)
        if !NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce")
        {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.performSegueWithIdentifier("toTutorial", sender: self)
        }
        
        //codice di diagnostica
        var requestTerapia = NSFetchRequest(entityName: "Terapia")
        requestTerapia.returnsObjectsAsFaults = false
        var listTerapia = context.executeFetchRequest(requestTerapia, error: nil)
        println("\(listTerapia!.count) elementi in Terapia")
        
        super.viewWillAppear(animated)
        
        
    }
    
    /*override func viewWillDisappear(animated: Bool)
    {
        if let navController = self.navigationController
        {
            navController.setToolbarHidden(true, animated: true)
        }
    }*/
    
    override func viewDidLoad() {
        
        self.editing = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "NSUpdateInterface", object: nil)
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Indietro", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
