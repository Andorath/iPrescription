//
//  PrescriptionViewController.swift
//  iPrescription
//
//  Created by Marco on 28/06/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit
import CoreData

class PrescriptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var del: AppDelegate
    var context: NSManagedObjectContext
    var therapyList: [AnyObject]
    var selectedRow: String?
    
    var AddAlertSaveAction: UIAlertAction?
    
    @IBOutlet var tableView: UITableView
    
    init(coder aDecoder: NSCoder!)
    {
        del = UIApplication.sharedApplication().delegate as AppDelegate
        context = del.managedObjectContext
        therapyList = [AnyObject]()
        
        var request = NSFetchRequest(entityName: "Terapia")
        request.returnsObjectsAsFaults = false
        var sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        therapyList = context.executeFetchRequest(request, error: nil)
        
        super.init(coder: aDecoder)
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }

    @IBAction func addTherapy(sender: AnyObject)
    {
        
        let addAlertView = UIAlertController(title: "New Prescription", message: "Insert a name for this prescription", preferredStyle: UIAlertControllerStyle.Alert)
        
        addAlertView.addTextFieldWithConfigurationHandler({textField in
                textField.placeholder = "Title"
                textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
                textField.delegate = self
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:",    name: UITextFieldTextDidChangeNotification, object: textField)})
        
        func removeTextFieldObserver()
        {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: addAlertView.textFields[0])
        }
        
        
        let addAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { alert in
            
            var stringNoSpaces: NSString = ((addAlertView.textFields[0] as UITextField).text as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if self.alreadyExists(stringNoSpaces)
            {
                let alreadyExistAlert = UIAlertController(title: "Warning!", message: "There's already a prescription with this name", preferredStyle: UIAlertControllerStyle.Alert)
                alreadyExistAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
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
            
                removeTextFieldObserver()
            }
            
        })
        
        addAction.enabled = false
        
        AddAlertSaveAction = addAction
        
        addAlertView.addAction(UIAlertAction(title: "Cancel",
                                             style: UIAlertActionStyle.Default,
            handler: {action in removeTextFieldObserver()}))
        
        addAlertView.addAction(addAction)
        
        
        
        self.presentViewController(addAlertView, animated: true, completion: nil)
        
        
    }
    
    //handler
    func handleTextFieldTextDidChangeNotification (notification: NSNotification)
    {
        let textField = notification.object as UITextField
        AddAlertSaveAction!.enabled = textField.text.utf16count >= 1
    }
    
    func updateInterface ()
    {
        var requestTerapia = NSFetchRequest(entityName: "Terapia")
        var sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        requestTerapia.sortDescriptors = [sortDescriptor]
        therapyList = context.executeFetchRequest(requestTerapia, error: nil)
        tableView.reloadData()
    }
    
    func alreadyExists (name: String) -> Bool
    {
        var request = NSFetchRequest(entityName: "Terapia")
        request.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "nome = %@", name)
        request.predicate = predicate
        var results = context.executeFetchRequest(request, error: nil)
        
        return !results.isEmpty
    }
    
    //Funzioni di modifica
    
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
        
        if editing == true
        {
            println("editing")
            self.navigationItem.rightBarButtonItem.title = "Done"
        }
        else
        {
            self.navigationItem.rightBarButtonItem.title = "Edit"
        }
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            var delObj = therapyList[indexPath.row] as NSManagedObject
            
            //Rimuoviamo il record dal database
            context.deleteObject(delObj)
            context.save(nil)
            
            //Rimuovimao dal TherapyList
            therapyList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath), withRowAnimation: UITableViewRowAnimation.Right)
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        if therapyList.count == 0
        {
            self.editing = false
            self.navigationItem.rightBarButtonItem.title = "Edit"
            self.navigationItem.rightBarButtonItem.enabled = false
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = true
        }
        
        return therapyList.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        var cell: PrescriptionTableViewCell? = tableView.dequeueReusableCellWithIdentifier("my Cell") as? PrescriptionTableViewCell
    
        if cell == nil
        {
            cell = PrescriptionTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "my Cell")
        }
        
        var terapia: NSManagedObject = therapyList[indexPath.row] as NSManagedObject
        cell!.textLabel.text = terapia.valueForKey("nome") as String
        
        cell!.imageView.image = UIImage(named: "Prescription.png")
        var medicineList = (terapia.valueForKey("medicine") as NSOrderedSet).array
        cell!.detailTextLabel.text = "\(medicineList.count) medicine/s"
        
        
        return cell
    }
    
    func tableView(tableView: UITableView!, willSelectRowAtIndexPath indexPath: NSIndexPath!) -> NSIndexPath!
    {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        selectedRow = cell.textLabel.text
        return indexPath
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        if self.editing
        {
            var alertChange = UIAlertController(title: "Editing prescription name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alertChange.addTextFieldWithConfigurationHandler({textField in
                textField.text = self.selectedRow
                textField.delegate = self
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:",    name: UITextFieldTextDidChangeNotification, object: textField)})
            
            func removeTextFieldObserver()
            {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: alertChange.textFields[0])
            }
            
            let changeAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default, handler: { alert in
                
                var stringNoSpaces: NSString = ((alertChange.textFields[0] as UITextField).text as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                if self.alreadyExists(stringNoSpaces)
                {
                    let alreadyExistAlert = UIAlertController(title: "Warning!", message: "There's already a prescription with this name", preferredStyle: UIAlertControllerStyle.Alert)
                    alreadyExistAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alreadyExistAlert, animated: true, completion: nil)
                }
                else
                {
                    
                    var selected = self.therapyList[self.tableView.indexPathForSelectedRow().row] as NSManagedObject
                    selected.setValue((alertChange.textFields[0] as UITextField).text, forKey: "nome")
                    self.context.save(nil)
                    
                    var cell = tableView.cellForRowAtIndexPath(indexPath!)
                    cell.textLabel.text = (alertChange.textFields[0] as UITextField).text
                    
                    self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow(), animated: true)
                    removeTextFieldObserver()
                }
                
                
            
                })
            
            
            AddAlertSaveAction = changeAction
            
            alertChange.addAction(UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Default,
            handler: {action in
                
                    self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow(), animated: true)
                    removeTextFieldObserver()}))
            
            alertChange.addAction(changeAction)
            
            self.presentViewController(alertChange, animated: true, completion: nil)
        }
        
    }
    
    func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool
    {
        if self.editing == true
        {
            return false
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)
    {
        if segue.identifier == "toMedicines"
        {
            var destinationController = segue.destinationViewController as MedicineTableViewController
            destinationController.selectedPrescription = selectedRow!
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow(), animated: true)
        NSNotificationCenter.defaultCenter().postNotificationName("NSUpdateInterface", object: nil)
        
        //codice di diagnostica
        var requestTerapia = NSFetchRequest(entityName: "Terapia")
        requestTerapia.returnsObjectsAsFaults = false
        var listTerapia = context.executeFetchRequest(requestTerapia, error: nil)
        println("\(listTerapia.count) elementi in Terapia")
        
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        
        self.editing = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "NSUpdateInterface", object: nil)
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

}
