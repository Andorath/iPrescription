//
//  AddFormTableViewController.swift
//  iPrescription
//
//  Created by Marco on 30/06/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATO

import UIKit
import CoreData

class AddFormTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var insertDone: Bool = false
    var newPrescription: Bool = true
    var prescription: NSManagedObject?
    var medicineList = [NSManagedObject]()
    var medicineSet: NSMutableOrderedSet = NSMutableOrderedSet()
    var currentTextField: UIView?

    
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var dosageFormTextField: UITextField!
    @IBOutlet var dosageTextField: UITextField!
    @IBOutlet var periodTextField: UITextField!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var doctorTextField: UITextField!
    

    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        currentTextField?.resignFirstResponder()
        //UNIVERSALIZZATA
        let del = UIApplication.sharedApplication().delegate as AppDelegate
        let context = del.managedObjectContext
        
        if newPrescription
        {
            context!.deleteObject(prescription!)
            NSNotificationCenter.defaultCenter().postNotificationName("NSUpdateInterface", object: nil)
        }
        
        if medicineList.count > 0
        {
            for elem in medicineList
            {
                context!.deleteObject(elem)
            }
                
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func doneButtonPressed(sender: AnyObject)
    {
        if newPrescription && nameTextField.text == ""
        {
            currentTextField?.resignFirstResponder()
            var nome = self.prescription!.valueForKey("nome") as String
            let alert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup medicina vuota"), message: String(format:NSLocalizedString("Non è stato inserito alcun nome per la medicina. La prescrizione %@ sarà vuota. Vuoi comunque continuare?", comment: "Messaggio popup nome medicina vuota"), nome), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: "Annulla comando popup medicina vuota"), style: UIAlertActionStyle.Default, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok comando popup medicina vuota"), style: UIAlertActionStyle.Default, handler: {alert in
                
                    let del = UIApplication.sharedApplication().delegate as AppDelegate
                    let context = del.managedObjectContext
                    context!.save(nil)
                
                    NSNotificationCenter.defaultCenter().postNotificationName("NSUpdateInterface", object: nil)
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                
                }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if nameTextField.text == ""
        {
            currentTextField?.resignFirstResponder()
            
            let alert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup medicina vuota 2"), message: NSLocalizedString("Non è stato inserito alcun nome per la medicina", comment: "Messaggio popup medicina vuota 2"), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok comando popup medicina vuota 2"), style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            currentTextField?.resignFirstResponder()
            
            let del = UIApplication.sharedApplication().delegate as AppDelegate
            let context = del.managedObjectContext
            
            var medicine = NSEntityDescription.insertNewObjectForEntityForName("Medicina", inManagedObjectContext: context!) as NSManagedObject
            
            medicine.setValue(nameTextField.text, forKey: "nome")
            medicine.setValue(dosageFormTextField.text, forKey: "forma")
            medicine.setValue(dosageTextField.text, forKey: "dosaggio")
            medicine.setValue(periodTextField.text, forKey: "durata")
            medicine.setValue(noteTextView.text, forKey: "note")
            medicine.setValue(doctorTextField.text, forKey: "dottore")
            medicine.setValue(nil, forKey: "data_ultima_assunzione")
            
            //crea un identificatore univoco e lo asseno all'oggetto
            let id = NSUUID().UUIDString
            medicine.setValue(id, forKey: "id")
            
            //medicineSet.addObject(medicine)
            medicineList.append(medicine)

            medicineSet.addObjectsFromArray(self.medicineList)
            prescription!.setValue(self.medicineSet, forKey: "medicine")
            context?.save(nil)
            
            //Codice di diagnostica
            var requestTerapia = NSFetchRequest(entityName: "Terapia")
            var listTerapia = context?.executeFetchRequest(requestTerapia, error: nil)
            var requestMedicina = NSFetchRequest(entityName: "Medicina")
            var listMedicina = context?.executeFetchRequest(requestMedicina, error: nil)
            
            println("\(listTerapia!.count) elementi in Terapia e \(listMedicina!.count) elementi in Medicina")
            
            NSNotificationCenter.defaultCenter().postNotificationName("NSUpdateInterface", object: nil)
            
            if newPrescription
            {
                var nome = self.prescription!.valueForKey("nome") as String
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewControllerWithIdentifier("medicineList") as MedicineTableViewController
                myVC.selectedPrescription = nome
                let presentingVC = self.navigationController!.presentingViewController as UINavigationController
                
                self.dismissViewControllerAnimated(true, completion: {presentingVC.pushViewController(myVC, animated: true)
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Indietro", comment: "Back button da add medicine"), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)})
            }
            else
            {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
        
        
    }
    
    //funioni ausiliarie
    func forcedFirstResponder()
    {
        currentTextField?.becomeFirstResponder()
    }
    
    func dismissKeyboard()
    {
        if noteTextView.isFirstResponder()
        {
            noteTextView.resignFirstResponder()
            
        }
    }
    
    

    
    //Codice Delegato di testo
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        if textField == nameTextField
        {
            textField.resignFirstResponder()
            
        }
        else if textField == dosageFormTextField
        {
            dosageTextField.becomeFirstResponder()
        }
        else if textField == dosageTextField
        {
            periodTextField.becomeFirstResponder()
        }
        else if textField == periodTextField
        {
            periodTextField.resignFirstResponder()
        }
        else if textField == doctorTextField
        {
            doctorTextField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField!)
    {
        currentTextField = textField
    }
    
    func textViewDidBeginEditing(textView: UITextView!) -> Bool
    {
        currentTextField = textView
        
        return true
    }
    
    
    
    //Codice UIResponder
    
    override func viewWillAppear(animated: Bool)
    {
        var userInfo = ["currentController" : self]
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }

    override func viewDidLoad() {
        
        let del = UIApplication.sharedApplication().delegate as AppDelegate
        let context = del.managedObjectContext
        
        medicineSet = (prescription!.valueForKey("medicine") as NSMutableOrderedSet).mutableCopy() as NSMutableOrderedSet
        
        var toolBar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        toolBar.barStyle = UIBarStyle.Default
        var doneButton = UIBarButtonItem(title: NSLocalizedString("Fine", comment: "Done della toolbar add medicine"), style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
        doneButton.tintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 1)
        var arrayItem = [doneButton]
        toolBar.items = arrayItem
        
        noteTextView.inputAccessoryView = toolBar
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
