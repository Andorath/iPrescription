
//
//  DrugAddingPerfrmer.swift
//  iPrescription
//
//  Created by Marco Salafia on 09/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit

protocol PrescriptionAddingDelegate
{
    var delegator: UITableViewController? {get}
    var prescription: Prescription? {get set}
    
    init(delegator: UITableViewController)
    
    func initAlertController()
    func showAlertController()
}

class PrescriptionAddingPerformer : NSObject, PrescriptionAddingDelegate, UITextFieldDelegate
{
    var delegator: UITableViewController?
    var prescription: Prescription?
    
    var alertController: UIAlertController?
    var saveAction: UIAlertAction?
    
    required init(delegator: UITableViewController)
    {
        super.init()
        self.delegator = delegator
        self.prescription = nil
        initAlertController()
    }
    
    func initAlertController()
    {
        alertController = UIAlertController(title: NSLocalizedString("Nuova Prescrizione", comment: "Titolo popup creazione prescrizione"),
                                            message: NSLocalizedString("Inserisci un nome per questa prescrizione",
                                                                       comment: "Messaggio popup creazione nuova prescrizione"),
                                            preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(textFieldConfigurationHandler)
        
        alertController!.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: "Annulla popup creazione nuova prescrizione"),
                                                style: UIAlertActionStyle.Cancel,
                                                handler: nil))
        
        let addPrescription = initAddPrescriptionAction()
        alertController!.addAction(addPrescription)
    }
    
    func textFieldConfigurationHandler(textField: UITextField)
    {
        textField.placeholder = NSLocalizedString("es: Terapia Antibiotica", comment: "Placeholder popup creazione nuova prescrizione")
        textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
        textField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "handleTextFieldTextDidChangeNotification:",
                                                         name: UITextFieldTextDidChangeNotification,
                                                         object: textField)
    }
    
    func initAddPrescriptionAction() -> UIAlertAction
    {
        let addAction = UIAlertAction(title: NSLocalizedString("Salva", comment: "Azione salva popup creazione nuova prescrizione"),
                                      style: UIAlertActionStyle.Default,
                                      handler: validityHandler)
        addAction.enabled = false
        saveAction = addAction
        return addAction
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
                                                          message: NSLocalizedString("Esiste già una prescrizione con questo nome",
                                                          comment: "Messaggio popup errore prescrizione"),
                                                          preferredStyle: UIAlertControllerStyle.Alert)
                
                alreadyExistAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok popup errore creazione prescrizione"),
                                                          style: UIAlertActionStyle.Default,
                                                          handler: nil))
                
                delegator!.presentViewController(alreadyExistAlert, animated: true, completion: nil)
            }
            else
            {
                prescription = Prescription(nome: stringNoSpaces)
                presentDrugForm()
            }
        }
    }
    
    func prescriptionExists(name: String) -> Bool
    {
        let prescriptionModel = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptionsModel!
        return prescriptionModel.alreadyExistsPrescription(name)
    }
    
    func presentDrugForm()
    {
        delegator!.performSegueWithIdentifier("toAddDrugs", sender: self)
    }
    
    func handleTextFieldTextDidChangeNotification (notification: NSNotification)
    {
        if let textField = notification.object as? UITextField
        {
            saveAction!.enabled = textField.text!.utf16.count >= 1
        }
    }
    
    func showAlertController()
    {
        if delegator!.editing
        {
            delegator!.setEditing(false, animated: true)
        }
        
        delegator!.presentViewController(alertController!, animated: true, completion: nil)
    }
}
