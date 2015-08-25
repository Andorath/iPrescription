//
//  DrugTableViewController.swift
//  iPrescription
//
//  Created by Marco Salafia on 11/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class DrugTableViewController: UITableViewController
{
    var prescriptionsModel: PrescriptionList = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptionsModel!
    
    private var currentPrescription: Prescription?
    
    // MARK: - Metodi di classe

    override func viewDidLoad()
    {
        addAllNecessaryObservers()
        initUserInterface()
        
        super.viewDidLoad()
    }
    
    func addAllNecessaryObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "MGSUpdateDrugsInterface", object: nil)
    }
    
    func initUserInterface()
    {
        self.title = currentPrescription?.nome
    }
    
    func updateInterface()
    {
        currentPrescription = prescriptionsModel.updateConsistencyForPrescription(currentPrescription!)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func setCurrentPrescription(presc: Prescription)
    {
        self.currentPrescription = presc
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return prescriptionsModel.numberOfDrugsForPrescription(currentPrescription!)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell 
    {
        let cell: MedicineTableViewCell = tableView.dequeueReusableCellWithIdentifier("my Cell", forIndexPath: indexPath) as! MedicineTableViewCell

        let drugList = prescriptionsModel.getDrugsFromPrescription(currentPrescription!)
        let drug = drugList[indexPath.row]
        cell.textLabel?.text = drug.nome
        cell.imageView?.image = UIImage(named: "Medicine.png")
        
        if prescriptionsModel.thereAreNotificationsForDrug(drug)
        {
            cell.alarmIcon.image = UIImage(named: "alarm_trasparente.png")
        }
        else
        {
            cell.alarmIcon.image = nil
        }

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            prescriptionsModel.deleteDrugForPrescription(currentPrescription!, atIndex: indexPath.row)
            currentPrescription = prescriptionsModel.updateConsistencyForPrescription(currentPrescription!)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
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
                            if let _ = sender as? UIBarButtonItem
                            {
                                formViewController.setCurrentPrescription(currentPrescription!)
                            }
                        }
                    }
                
                case "toDetail":
                    
                    if let destinationController = segue.destinationViewController as? DrugDetailController
                    {
                        if let selectedIndex = self.tableView.indexPathForCell(sender as! MedicineTableViewCell)
                        {
                            let drug = prescriptionsModel.getDrugAtIndex(selectedIndex.row ,forPrescription: currentPrescription!)
                            destinationController.setCurrentDrug(drug)
                        }

                    }
                
                default:
                    break
            }
        }
    }

}
