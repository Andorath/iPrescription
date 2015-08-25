//
//  PrescriptionEditingPerformer.swift
//  iPrescription
//
//  Created by Marco Salafia on 10/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit

protocol PrescriptionEditingDelegate
{
    var delegator: UITableViewController? {get}
    var prescription: Prescription? {get set}
    
    init(delegator: UITableViewController, prescription: Prescription)
    
    func performEditingProcedure()
}

class PrescriptionEditingPerformer: NSObject, PrescriptionEditingDelegate, UITextFieldDelegate
{
    var delegator: UITableViewController?
    var prescription: Prescription?
    
    var alertController: UIAlertController?
    var editAction: UIAlertAction?
    
    required init(delegator: UITableViewController, prescription: Prescription)
    {
        super.init()
        self.delegator = delegator
        self.prescription = prescription
        initAlertController()
    }
    
    func initAlertController()
    {
        alertController = UIAlertController(title: NSLocalizedString("Modifica nome della prescrizione", comment: "Titolo popup modifica nome prescrizione"),
                                            message: NSLocalizedString("Cambia il nome della Prescrizione", comment: "Messaggio vuoto popup modifica nome prescrizione"),
                                            preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(textFieldConfigurationHandler)
        
        alertController!.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: "Annulla popup modifica prescrizione"),
                                                 style: UIAlertActionStyle.Cancel,
                                                 handler: nil))
        
        let editPrescriptionAction = initEditPrescriptionAction()
        editAction = editPrescriptionAction
        alertController!.addAction(editPrescriptionAction)
    }
    
    func textFieldConfigurationHandler(textField: UITextField)
    {
        textField.text = prescription?.nome
        textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
        textField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "handleTextFieldTextDidChangeNotification:",
                                                         name: UITextFieldTextDidChangeNotification,
                                                         object: textField)
    }
    
    func handleTextFieldTextDidChangeNotification (notification: NSNotification)
    {
        let textField = notification.object as! UITextField
        editAction!.enabled = textField.text!.utf16.count >= 1
    }
    
    func initEditPrescriptionAction() -> UIAlertAction
    {
        let changeAction = UIAlertAction(title: NSLocalizedString("Modifica", comment: "comando Cambia popup cambiamento nome prescrizione"),
                                         style: UIAlertActionStyle.Default,
                                         handler: validityHandler)
        
        return changeAction
    }
    
    func validityHandler(action: UIAlertAction)
    {
        if let stringNoSpaces = alertController!.textFields?[0].text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        {
            if stringNoSpaces.isEmpty
            {
                let emptyNameAlert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup errore nome prescrizione vuoto"),
                                                       message: NSLocalizedString("Non è possibile creare prescrizioni con il nome vuoto!",
                                                       comment: "Messaggio popup errore prescrizione"),
                                                       preferredStyle: UIAlertControllerStyle.Alert)
                
                emptyNameAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok popup errore creazione prescrizione"),
                                                       style: UIAlertActionStyle.Default,
                                                       handler: nil))
                
                delegator!.presentViewController(emptyNameAlert, animated: true, completion: nil)
            }
            else if prescriptionExists(stringNoSpaces)
            {
                let alreadyExistAlert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup errore nome prescrizione"),
                                                          message: NSLocalizedString("Esiste già una prescrizione con questo nome", comment: "Messaggio popup errore prescrizione"),
                                                          preferredStyle: UIAlertControllerStyle.Alert)
                
                alreadyExistAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok popup errore creazione prescrizione"),
                    style: UIAlertActionStyle.Default,
                    handler: nil))
                
                delegator!.presentViewController(alreadyExistAlert, animated: true, completion: nil)
            }
            else
            {
                editPrescriptionName(stringNoSpaces)
            }
        }
    }
    
    func prescriptionExists(name: String) -> Bool
    {
        let prescriptionModel = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptionsModel!
        return prescriptionModel.alreadyExistsPrescription(name)
    }
    
    func editPrescriptionName(newName: String)
    {
        let prescriptionModel = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptionsModel!
        prescriptionModel.setNewNameForPrescription(prescription!, withNewName: newName)
    }
    
    func performEditingProcedure()
    {
        delegator?.presentViewController(alertController!, animated: true, completion: nil)
    }
    
}