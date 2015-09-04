//
//  NPrescriptionTableViewController.swift
//  iPrescription
//
//  Created by Marco Salafia on 08/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class NPrescriptionTableViewController: UITableViewController
{
    lazy var prescriptionsModel: PrescriptionList = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptionsModel!
    
    var prescriptionDelegate: PrescriptionAddingDelegate?
    var rateDelegate = RateReminder.sharedInstance

    /// ---
    /// - note: Genera un avviso a runtime dovuto a:
    ///    rateDelegate?.rateMe()
    /// in quanto si tenta al suo interno di presentare un AlertController mentre questi ancora è "detached"
    /// dalla gerarchia dei controller. Dovrebbe essere posizionato nel viewDidAppear ma richiede di cambiare 
    /// l'algoritmo di Rate Reminder.
    /// ---
    
    override func viewDidLoad()
    {
        addAllNecessaryObservers()
        setUserInterfaceComponents()
        rateDelegate.rateMeWithPresenter(self)
        super.viewDidLoad()
    }
    
    func addAllNecessaryObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "MGSUpdatePrescriptionInterface", object: nil)
    }
    
    func setUserInterfaceComponents()
    {
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func updateInterface()
    {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        showInfoAtFirstLaunch()
    }
    
    func showInfoAtFirstLaunch()
    {
        if !NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce")
        {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.performSegueWithIdentifier("toInfo", sender: self)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Metodi relativi al Controller
    
    @IBAction func addNewPrescription(sender: AnyObject)
    {
        prescriptionDelegate = PrescriptionAddingPerformer(delegator: self)
        prescriptionDelegate!.showAlertController()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return prescriptionsModel.numberOfPrescriptions()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: PrescriptionTableViewCell? = tableView.dequeueReusableCellWithIdentifier("my Cell") as? PrescriptionTableViewCell
        let selectedPrescription = prescriptionsModel.getPrescriptionAtIndex(indexPath.row)
        cell!.textLabel?.text = selectedPrescription.nome
        cell!.imageView?.image = IPrescriptionStyleKit.imageOfPrescriptionIcon
        
        // TODO: Fare Refactoring di questa parte in un metodo di forwarding.
        var medString: String
        let drugsNumber = prescriptionsModel.numberOfDrugsForPrescriptionAtIndex(indexPath.row)
        if drugsNumber == 1
        {
            medString = NSLocalizedString("Medicina", comment: "Sottotitolo riga della prescrizione al singolare")
        }
        else
        {
            medString = NSLocalizedString("Medicine", comment: "Sottotitolo riga della prescrizione al plurale")
        }
        
        let notificationNumber = prescriptionsModel.numberOfNotificationsForPrescriptionAtIndex(indexPath.row)
        
        if notificationNumber == 0
        {
            cell!.detailTextLabel!.text = "\(drugsNumber) " + medString
        }
        else if notificationNumber == 1
        {
            cell!.detailTextLabel!.text = "\(drugsNumber) " + medString +
                String(format: NSLocalizedString(" - %d Notifica", comment: "sottotitolo prescrizione per le notifiche al singolare"), notificationNumber)
        }
        else
        {
            cell!.detailTextLabel!.text = "\(drugsNumber) " + medString + String(format: NSLocalizedString(" - %d Notifiche", comment: "sottotitolo prescrizione per le notifiche al plurale"), notificationNumber)
        }

        return cell!
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            prescriptionsModel.deletePrescriptionAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let editAction = getEditRowAction()
        let deleteAction = getDeleteRowAction()
        
        return [deleteAction, editAction]
    }
    
    func getEditRowAction() -> UITableViewRowAction
    {
        let editLabel = NSLocalizedString("Modifica", comment: "Azione modifica")
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: editLabel)
        {
            (action, index) in
            let prescription = self.prescriptionsModel.getPrescriptionAtIndex(index.row)            
            let editingDelegate: PrescriptionEditingDelegate = PrescriptionEditingPerformer(delegator: self, prescription: prescription)
            editingDelegate.performEditingProcedure()
            
        }
        editAction.backgroundColor = UIColor(red: 35.0/255.0, green: 146.0/255.0, blue: 199.0/255.0, alpha: 1)
        
        return editAction
    }
    
    func getDeleteRowAction() -> UITableViewRowAction
    {
        let deleteLabel = NSLocalizedString("Elimina", comment: "Azione cancella")
        let tv: UITableView? = tableView
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: deleteLabel)
        {
            (action, index) in tv!.dataSource?.tableView!(tv!, commitEditingStyle: .Delete, forRowAtIndexPath: index)
        }
        
        return deleteAction
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        if self.editing
        {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let segueId = segue.identifier
        {
            switch segueId
            {
                case "toAddDrugs":
                    
                    if let destinationNavigationController = segue.destinationViewController as? UINavigationController
                    {
                        if let formViewController = (destinationNavigationController.viewControllers[0] as? AddDrugFormController)
                        {
                            if let presenter = sender as? PrescriptionAddingDelegate
                            {
                                formViewController.setCurrentPrescription(presenter.prescription!)
                                formViewController.workingOnNewPrescription()
                            }
                        }
                    }
                case "toDrugs":
                    
                    if let destinationDrugController = segue.destinationViewController as? DrugTableViewController
                    {
                        if let cell = sender as? PrescriptionTableViewCell
                        {
                            if let selectedIndex = self.tableView.indexPathForCell(cell)
                            {
                                let prescription = prescriptionsModel.getPrescriptionAtIndex(selectedIndex.row)
                                destinationDrugController.setCurrentPrescription(prescription)
                            }
                        }
                        else if let presenter = sender as? AddDrugFormController
                        {
                            destinationDrugController.setCurrentPrescription(presenter.prescription!)
                        }
                    }
                
                default:
                    print("default")
            }
        }
        
    }
}
