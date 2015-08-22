//
//  AddDrugFormController.swift
//  iPrescription
//
//  Created by Marco Salafia on 09/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class AddDrugFormController: UITableViewController, UITextFieldDelegate, UITextViewDelegate
{
    var currentResponder: UIResponder?
    
    private var prescription: Prescription?
    private var newPrescription: Bool = false
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dosageTextField: UITextField!
    @IBOutlet weak var dosageFormTextField: UITextField!
    @IBOutlet weak var periodTextField: UITextField!
    @IBOutlet weak var doctorTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    // MARK: - Metodi di classe
    
    override func viewDidLoad()
    {
        noteTextView.inputAccessoryView = getDoneToolbar()
        super.viewDidLoad()
    }
    
    func getDoneToolbar() -> UIToolbar
    {
        let doneToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Fine", comment: "Done della toolbar add medicine"),
            style: UIBarButtonItemStyle.Done,
            target: self,
            action: "dismissKeyboard")
        
        doneButton.tintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 1)
        let arrayItem = [doneButton]
        doneToolbar.items = arrayItem
        
        return doneToolbar
    }
    
    func dismissKeyboard()
    {
        if noteTextView.isFirstResponder()
        {
            noteTextView.resignFirstResponder()
            
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        nameTextField.becomeFirstResponder()
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func setCurrentPrescription(prescription: Prescription)
    {
        self.prescription = prescription
    }
    
    func workingOnNewPrescription()
    {
        self.newPrescription = true
    }

    /* 
    *  Questo metodo ha davvero tanti comportamenti che sarebbe carino sistemare
    *  in un metodo polimorfico ma non ho trovato come fare. Studiarci sopra
    *  durante la fase di refactoring.
    */
    
    @IBAction func doneAction(sender: AnyObject)
    {
        currentResponder?.resignFirstResponder()
        
        if textFiedIsEmpty(nameTextField)
        {
            
            if newPrescription
            {
                showEmptyPrescriptionAlertForNewPrescription()
            }
            else
            {
                showEmptyDrugAlert()
            }
        }
        else
        {
            addDrug()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func textFiedIsEmpty(textField: UITextField) -> Bool
    {
        if let textNoSpaces = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        {
            return textNoSpaces.isEmpty
        }
        
        return true
    }
    
    func showEmptyPrescriptionAlertForNewPrescription()
    {
        if let nome = prescription?.nome
        {
            let alert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup medicina vuota"),
                                          message: String(format:NSLocalizedString("Non è stato inserito alcun nome per la medicina. La prescrizione %@ sarà vuota. Vuoi comunque continuare?",
                                                          comment: "Messaggio popup nome medicina vuota"),
                                                          nome),
                                          preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: "Annulla comando popup medicina vuota"),
                                          style: UIAlertActionStyle.Default,
                                          handler: nil))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok comando popup medicina vuota"),
                style: UIAlertActionStyle.Default){
                                                     alert in
                                                              if let prescriptionModel = (UIApplication.sharedApplication().delegate as? AppDelegate)?.prescriptionsModel
                                                              {
                                                                  self.storeNewPrescriptionInModel(prescriptionModel)
                                                                  self.dismissViewControllerAnimated(true, completion: nil)
                                                              }
                                                  })
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func storeNewPrescriptionInModel(model: PrescriptionList)
    {
        model.addPrescription(self.prescription!)
    }
    
    func showEmptyDrugAlert()
    {
        let alert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup medicina vuota 2"),
                                      message: NSLocalizedString("Non è stato inserito alcun nome per la medicina",
                                      comment: "Messaggio popup medicina vuota 2"), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok comando popup medicina vuota 2"),
                                      style: UIAlertActionStyle.Default,
                                      handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func addDrug()
    {
        let drug: Drug = buildCurrentDrug()
        prescription!.medicine.append(drug)
        
        if let prescriptionModel = (UIApplication.sharedApplication().delegate as? AppDelegate)?.prescriptionsModel
        {
            if newPrescription
            {
                storeNewPrescriptionInModel(prescriptionModel)
            }
            else
            {
                storeDrugForExistingPrescriptionInModel(prescriptionModel)
            }
        }
    }
    
    func buildCurrentDrug() -> Drug
    {
        return Drug(name: nameTextField.text!,
                    dosage: dosageTextField.text!,
                    doc: doctorTextField.text!,
                    period: periodTextField.text!,
                    form: dosageFormTextField.text!,
                    note: noteTextView.text)
    }
    
    func storeDrugForExistingPrescriptionInModel(model: PrescriptionList)
    {
        model.addDrugForPrescription(prescription!)
    }
    
    @IBAction func cancelAction(sender: AnyObject)
    {
        currentResponder?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Text Delegate
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        currentResponder = textField
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        currentResponder = textView
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == nameTextField
        {
            textField.resignFirstResponder()
        }
        else if textField == dosageTextField
        {
            dosageFormTextField.becomeFirstResponder()
        }
        else if textField == dosageFormTextField
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

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
