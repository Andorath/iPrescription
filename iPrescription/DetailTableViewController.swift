//
//  DetailTableViewController.swift
//  iPrescription
//
//  Created by Marco on 07/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATO

import UIKit
import CoreData

class DetailTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var selectedMedicine: NSManagedObject?
    var selectedPrescription: String?
    var edit: Bool = false
    var userInfo: [NSObject : AnyObject]?
    
    var del: AppDelegate
    var context: NSManagedObjectContext
    
    @IBOutlet weak var gestioneDataButton: UIButton!
    @IBOutlet weak var dataAssunzione: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var dosageFormTextField: UITextField!
    @IBOutlet var dosageTextField: UITextField!
    @IBOutlet var periodTextField: UITextField!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var doctorTextField: UITextField!

    required init?(coder aDecoder: NSCoder)
    {
        del = UIApplication.sharedApplication().delegate as! AppDelegate
        context = del.managedObjectContext!
        super.init(coder: aDecoder)
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        
        if editing == true
        {
            gestioneDataButton.enabled = false
            
            nameTextField.userInteractionEnabled = true
            nameTextField.borderStyle = UITextBorderStyle.RoundedRect
            dosageFormTextField.userInteractionEnabled = true
            dosageFormTextField.borderStyle = UITextBorderStyle.RoundedRect
            dosageTextField.userInteractionEnabled = true
            dosageTextField.borderStyle = UITextBorderStyle.RoundedRect
            periodTextField.userInteractionEnabled = true
            periodTextField.borderStyle = UITextBorderStyle.RoundedRect
            noteTextView.editable = true
            doctorTextField.userInteractionEnabled = true
            doctorTextField.borderStyle = UITextBorderStyle.RoundedRect
            
            let toolBar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
            toolBar.barStyle = UIBarStyle.Default
            let doneButton = UIBarButtonItem(title: NSLocalizedString("Fine", comment: "Done della Barbutton Detail"), style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
            doneButton.tintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 1)
            let arrayItem = [doneButton]
            toolBar.items = arrayItem
            
            noteTextView.inputAccessoryView = toolBar
        }
        else
        {
            gestioneDataButton.enabled = true
            
            nameTextField.userInteractionEnabled = false
            //nameTextField.allowsEditingTextAttributes = false
            nameTextField.borderStyle = UITextBorderStyle.None
            dosageFormTextField.userInteractionEnabled = false
            dosageFormTextField.borderStyle = UITextBorderStyle.None
            dosageTextField.userInteractionEnabled = false
            dosageTextField.borderStyle = UITextBorderStyle.None
            periodTextField.userInteractionEnabled = false
            periodTextField.borderStyle = UITextBorderStyle.None
            noteTextView.editable = false
            doctorTextField.userInteractionEnabled = false
            doctorTextField.borderStyle = UITextBorderStyle.None
            
            noteTextView.inputAccessoryView = nil
            
            //Salvataggio
            
            selectedMedicine!.setValue(nameTextField.text, forKey: "nome")
            selectedMedicine!.setValue(dosageFormTextField.text, forKey: "forma")
            selectedMedicine!.setValue(dosageTextField.text, forKey: "dosaggio")
            selectedMedicine!.setValue(periodTextField.text, forKey: "durata")
            selectedMedicine!.setValue(noteTextView.text, forKey: "note")
            selectedMedicine!.setValue(doctorTextField.text, forKey: "dottore")
            
            do {
                try context.save()
            } catch _ {
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("NSUpdateInterface", object: nil)
        }
    }
    
    //Blocco gestione data assunzione

    @IBAction func showAssunzioneSheet(sender: AnyObject)
    {
        let alertSheet = UIAlertController(title: NSLocalizedString("Data ultima assunzione", comment: "Titolo data di assunzione alert sheet"), message: NSLocalizedString("Come vuoi gestire la data dell'ultima assunzione?", comment: "Messaggio data di assunzione alert sheet"), preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertSheet.addAction(UIAlertAction(title: NSLocalizedString("Assumi il farmaco adesso", comment: "Comando 1 data di assunzione alert sheet"), style: UIAlertActionStyle.Default, handler: {alert in self.assumiFarmaco(NSDate())}))
        alertSheet.addAction(UIAlertAction(title: NSLocalizedString("Imposta la data manualmente", comment: "Comando 2 data di assunzione alert sheet"), style: UIAlertActionStyle.Default, handler: {alert in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewControllerWithIdentifier("changeDateNavigationController") as! UINavigationController
            self.presentViewController(myVC, animated: true, completion: nil)
        }))
        alertSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancella data", comment: "Comando 3 data di assunzione alert sheet"), style: UIAlertActionStyle.Destructive, handler: {alert in self.resetDataAssunzione()}))
        alertSheet.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: "Comando annulla data di assunzione sheet"), style: UIAlertActionStyle.Cancel, handler: nil))

        
        self.presentViewController(alertSheet, animated: true, completion: nil)
    }
    
    func assumiFarmaco(dataAssunzione: NSDate)
    {
        selectedMedicine!.setValue(dataAssunzione, forKey: "data_ultima_assunzione")
        do {
            try context.save()
        } catch _ {
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE dd MMMM hh:mm a"
        self.dataAssunzione.text = dateFormatter.stringFromDate(dataAssunzione)
        
    }
    
    func resetDataAssunzione()
    {
        dataAssunzione.text = ""
        selectedMedicine!.setValue(nil, forKey: "data_ultima_assunzione")
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func showAssunzioneAlert()
    {
        print("E' arrivato")
        var id: String = self.userInfo!["id"] as! NSString as String
        let prescription: String = self.userInfo!["prescrizione"] as! NSString as String
        let medicine: String = self.userInfo!["medicina"] as! NSString as String
        let memo: String = self.userInfo!["memo"] as! NSString as String
        
        //Creiamo l'avviso per l'assunzione del farmaco
        
        
        let alert = UIAlertController(title: medicine, message: String(format: NSLocalizedString("Prescrizione: %@\nMemo: %@\n\nVuoi assumere il farmaco adesso?", comment: "Messaggio popup notifica assunzione farmaco"), prescription, memo), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Comando no popup assunzione farmaco"), style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Si", comment: "Comando si popup assunzione farmaco"), style: UIAlertActionStyle.Default, handler: { alert in self.assumiFarmaco(NSDate())}))
        
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    
    //Metodi TableViewDelegate
    //E' stato necessario implementare tutti quelli che presentano IndexPath come parametro per non dare errore
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.None
    }
    
    //Funzioni delegato
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard()
    {
        if noteTextView.isFirstResponder()
        {
            noteTextView.resignFirstResponder()
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "toAddNotificationNavigationController"
        {
            var destination = segue.destinationViewController as! UINavigationController
            var myVC = destination.viewControllers[0] as! AddNotificationTableViewController
            myVC.medicina = nameTextField.text
            var id: AnyObject? = selectedMedicine?.valueForKey("id")
            myVC.uuid = id as? String;
            myVC.prescription = selectedPrescription
        }
        else if segue.identifier == "toNotificationList"
        {
            var selectedNotifications = [UILocalNotification]()
            var id: AnyObject? = selectedMedicine?.valueForKey("id")
            
            if let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
            {
                for notification in scheduledNotifications
                {
                    let userInfo = notification.userInfo
                    
                    if userInfo!["id"] as! String == id as! String
                    {
                        selectedNotifications.append(notification)
                    }
                }
            }
            
            var destination = segue.destinationViewController as! NotificationTableViewController
            destination.notifications = selectedNotifications
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        let userInfo = ["currentController" : self]
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Indietro", comment: "Backbutton detaiil"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
        {
            self.navigationController!.setToolbarHidden(false, animated: false)
        }
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {

        
        var viewControllers = self.navigationController!.viewControllers
        let n = viewControllers.count
        
        if !(viewControllers[n - 2] is MedicineTableViewController)
        {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let medicineController = storyboard.instantiateViewControllerWithIdentifier("medicineList") as! MedicineTableViewController
            medicineController.selectedMedicineName = selectedMedicine!.valueForKey("nome") as? String
            medicineController.selectedPrescription = selectedPrescription
            self.navigationController!.setViewControllers([medicineController, self], animated: true)
        }
        
        nameTextField.text = selectedMedicine!.valueForKey("nome") as! String
        dosageFormTextField.text = selectedMedicine!.valueForKey("forma") as! String
        dosageTextField.text = selectedMedicine!.valueForKey("dosaggio") as! String
        periodTextField.text = selectedMedicine!.valueForKey("durata") as! String
        noteTextView.text = selectedMedicine!.valueForKey("note") as! String
        doctorTextField.text = selectedMedicine!.valueForKey("dottore") as! String
        let data = selectedMedicine!.valueForKey("data_ultima_assunzione") as! NSDate?
        if data != nil
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE dd MMMM hh:mm a"
            dataAssunzione.text = dateFormatter.stringFromDate(data!)
        }
        else
        {
            dataAssunzione.text = ""
        }
        
        if let info = userInfo
        {
            self.showAssunzioneAlert()
        }
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


   

}
