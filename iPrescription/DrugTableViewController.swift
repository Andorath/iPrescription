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
    lazy var prescriptionsModel: PrescriptionList = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptions
    
    private var currentPrescription: Prescription?
    
    // MARK: - Metodi di classe

    override func viewDidLoad()
    {
        super.viewDidLoad()
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


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
