//
//  DrugDetailController.swift
//  iPrescription
//
//  Created by Marco Salafia on 17/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class DrugDetailController: UITableViewController, UITextFieldDelegate, UITextViewDelegate
{
    var prescriptionsModel: PrescriptionList = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptionsModel!
    
    var currentDrug: Drug?
    
    var alertInfo: (drug: Drug, prescription: Prescription, memo: String)?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastAssumptionLabel: UILabel!
    @IBOutlet weak var formTextField: UITextField!
    @IBOutlet weak var dosageTextField: UITextField!
    @IBOutlet weak var periodTextField: UITextField!
    @IBOutlet weak var doctorTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var gestioneDataButton: UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        addAllNecessaryObservers()
        updateFieldsFromCurrentDrug()
        setUserInterfaceComponents()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        showAssumptionAlertIfPresent()
    }
    
    func addAllNecessaryObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFieldsFromCurrentDrug", name: "MGSUpdateDrugsDetailInterface", object: nil)
    }
    
    func showAssumptionAlertIfPresent()
    {
        if let info = alertInfo
        {
            showAssumptionAlertForInfo(info)
            alertInfo = nil
        }
    }
    
    func updateFieldsFromCurrentDrug()
    {
        updateCurrentDrugConsistency()
        nameTextField.text = currentDrug?.nome
        
        if let date = currentDrug?.data_ultima_assunzione
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE dd MMMM hh:mm a"
            lastAssumptionLabel.text = dateFormatter.stringFromDate(date)
        }
        else
        {
            lastAssumptionLabel.text = ""
        }
        
        formTextField.text = currentDrug!.forma
        dosageTextField.text = currentDrug!.dosaggio
        periodTextField.text = currentDrug!.durata
        doctorTextField.text = currentDrug!.dottore
        noteTextView.text = currentDrug!.note
    }
    
    func setUserInterfaceComponents()
    {
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func setCurrentDrug(drug: Drug)
    {
        self.currentDrug = drug
    }
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        
        if editing == true
        {
            enableEditingUI()
        }
        else
        {
            if nameTextField.text!.isEmpty
            {
                showEmptyDrugAlert()
                self.editing = true
            }
            else
            {
                disableEditingUI()
                updateCurrentDrugFromUI()
            }
        }
    }
    
    func enableEditingUI()
    {
        gestioneDataButton.enabled = false
        
        nameTextField.userInteractionEnabled = true
        nameTextField.borderStyle = UITextBorderStyle.RoundedRect
        nameTextField.backgroundColor = IPrescriptionStyleKit.tutorialColor
        formTextField.userInteractionEnabled = true
        formTextField.borderStyle = UITextBorderStyle.RoundedRect
        formTextField.backgroundColor = IPrescriptionStyleKit.tutorialColor
        dosageTextField.userInteractionEnabled = true
        dosageTextField.borderStyle = UITextBorderStyle.RoundedRect
        dosageTextField.backgroundColor = IPrescriptionStyleKit.tutorialColor
        periodTextField.userInteractionEnabled = true
        periodTextField.borderStyle = UITextBorderStyle.RoundedRect
        periodTextField.backgroundColor = IPrescriptionStyleKit.tutorialColor
        doctorTextField.userInteractionEnabled = true
        doctorTextField.borderStyle = UITextBorderStyle.RoundedRect
        doctorTextField.backgroundColor = IPrescriptionStyleKit.tutorialColor
        noteTextView.editable = true
        noteTextView.inputAccessoryView = getDoneToolbar()
    }
    
    func getDoneToolbar() -> UIToolbar
    {
        let doneToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Fine", comment: "Done della Barbutton Detail"),
            style: UIBarButtonItemStyle.Done,
            target: self,
            action: "dismissKeyboard")
        
        doneButton.tintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 1)
        let arrayItem = [doneButton]
        doneToolbar.items = arrayItem
        
        return doneToolbar
    }
    
    func disableEditingUI()
    {
        gestioneDataButton.enabled = true
        
        nameTextField.userInteractionEnabled = false
        nameTextField.borderStyle = UITextBorderStyle.None
        nameTextField.backgroundColor = UIColor.whiteColor()
        formTextField.userInteractionEnabled = false
        formTextField.borderStyle = UITextBorderStyle.None
        formTextField.backgroundColor = UIColor.whiteColor()
        dosageTextField.userInteractionEnabled = false
        dosageTextField.borderStyle = UITextBorderStyle.None
        dosageTextField.backgroundColor = UIColor.whiteColor()
        periodTextField.userInteractionEnabled = false
        periodTextField.borderStyle = UITextBorderStyle.None
        periodTextField.backgroundColor = UIColor.whiteColor()
        doctorTextField.userInteractionEnabled = false
        doctorTextField.borderStyle = UITextBorderStyle.None
        doctorTextField.backgroundColor = UIColor.whiteColor()
        noteTextView.editable = false
        noteTextView.inputAccessoryView = nil
    }
    
    func showEmptyDrugAlert()
    {
        let alert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup medicina vuota editing detail"),
                                      message: NSLocalizedString("Non è stato inserito alcun nome per la medicina",
                                      comment: "Messaggio popup medicina vuota editing detail"), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok comando popup medicina vuota editing detail"),
                                      style: UIAlertActionStyle.Default,
                                      handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateCurrentDrugFromUI()
    {
        let lastDrug = Drug(name: nameTextField.text!,
                            dosage: dosageTextField.text!,
                            doc: doctorTextField.text!,
                            period: periodTextField.text!,
                            form: formTextField.text!,
                            note: noteTextView.text,
                            id: currentDrug!.id,
                            date_last_assumption: currentDrug!.data_ultima_assunzione)
        
        prescriptionsModel.updateDrug(lastDrug)
    }

/// - note: Questo metodo è stato necessario in quanto se si modifica la data di assunzione mediante una Action della
///         notifica la currentDrug rimane con la vecchia data ed è necessario aggiornarla. 
///         Questo metodo risolve questo leak di inconsistenza dell'attributo currentDrug.
///         Viene adoperato all'interno del metodo:
/// - updateFieldsFromCurrentDrug()
    
    func updateCurrentDrugConsistency()
    {
        currentDrug = prescriptionsModel.getDrugWithId(currentDrug!.id)
    }
    
    func showAssumptionAlertForInfo(info: (prescription: Prescription, drug: Drug, memo: String))
    {
        let alert = UIAlertController(title: info.drug.nome,
                                      message: String(format: NSLocalizedString("Prescrizione: %@\nMemo: %@\n\nVuoi assumere il farmaco adesso?",
                                                                                comment: "Messaggio popup notifica assunzione farmaco"),
                                                                                info.prescription.nome,
                                                                                info.memo),
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Comando no popup assunzione farmaco"),
                                      style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Si", comment: "Comando si popup assunzione farmaco"),
                                      style: UIAlertActionStyle.Default){
                                        alert in
                                        self.assumiFarmaco(NSDate())
                                    })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }

    
    @IBAction func manageDataAction(sender: AnyObject)
    {
        let alertSheet = UIAlertController(title: NSLocalizedString("Data ultima assunzione", comment: "Titolo data di assunzione alert sheet"),
                                           message: NSLocalizedString("Come vuoi gestire la data dell'ultima assunzione?",
                                           comment: "Messaggio data di assunzione alert sheet"),
                                           preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertSheet.addAction(UIAlertAction(title: NSLocalizedString("Assumi il farmaco adesso", comment: "Comando 1 data di assunzione alert sheet"),
                                           style: UIAlertActionStyle.Default){
                                                                                alert in
                                                                                self.assumiFarmaco(NSDate())
                                                                             })
        
        alertSheet.addAction(UIAlertAction(title: NSLocalizedString("Imposta la data manualmente", comment: "Comando 2 data di assunzione alert sheet"),
                                           style: UIAlertActionStyle.Default){
                                                                                alert in
                                                                                self.performSegueWithIdentifier("toEditDate", sender: self)
                                                                             })
        
        alertSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancella data", comment: "Comando 3 data di assunzione alert sheet"),
                                           style: UIAlertActionStyle.Destructive){
                                                                                    alert in self.resetDataAssunzione()
                                                                                 })
        alertSheet.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: "Comando annulla data di assunzione sheet"), style: UIAlertActionStyle.Cancel, handler: nil))
        
        
        self.presentViewController(alertSheet, animated: true, completion: nil)
    }
    
    func assumiFarmaco(dataAssunzione: NSDate)
    {
        prescriptionsModel.setDate(dataAssunzione, forDrug: currentDrug!)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE dd MMMM hh:mm a"
        lastAssumptionLabel.text = dateFormatter.stringFromDate(dataAssunzione)
        
    }
    
    func resetDataAssunzione()
    {
        prescriptionsModel.setDate(nil, forDrug: currentDrug!)
        lastAssumptionLabel.text = ""
    }
    
    func showNotificationEmptyAlert()
    {
        let alert = UIAlertController(title: NSLocalizedString("Nessuna Notifica", comment: "Titolo popup No Notification"),
            message: NSLocalizedString("Non ci sono notifiche per questo farmaco", comment: "Messaggio popup No Notification"),
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok Action no notification"),
            style: UIAlertActionStyle.Default,
            handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.None
    }
    
    // MARK: - Delegato di testo
    
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
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let segueId = segue.identifier
        {
            switch segueId
            {
                case "toAddNotification":
                
                    if let destinationNavigationController = segue.destinationViewController as? UINavigationController
                    {
                        if let addNotificationController = (destinationNavigationController.viewControllers[0] as? AddNotificationTableViewController)
                        {
                            addNotificationController.setCurrentDrug(currentDrug!)
                        }
                    }
                
                case "toNotificationsList":
                
                    if let destinationController = segue.destinationViewController as? NotificationsListController
                    {
                        destinationController.setNotificationsForDrug(currentDrug!)
                    }
                
            default:
                break
            }
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool
    {
        if identifier == "toNotificationsList"
        {
            let thereAreNotifications =  prescriptionsModel.thereAreNotificationsForDrug(currentDrug!)
            
            if !thereAreNotifications
            {
                if let cell = sender as? UITableViewCell
                {
                    if let lastIndexPath = tableView.indexPathForCell(cell)
                    {
                        tableView.deselectRowAtIndexPath(lastIndexPath, animated: true)
                    }
                }
                
                showNotificationEmptyAlert()
            }
            
            return thereAreNotifications
        }
        
        return true
    }
    
}
