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
    lazy var prescriptions: PrescriptionList? = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptions

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return prescriptions!.numberOfPrescriptions()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: PrescriptionTableViewCell? = tableView.dequeueReusableCellWithIdentifier("my Cell") as? PrescriptionTableViewCell
        let selectedPrescription = prescriptions?.getPrescriptionAtIndex(indexPath.row)
        cell!.textLabel?.text = selectedPrescription?.nome        
        cell!.imageView?.image = UIImage(named: "Prescription.png")
        var medString: String
        let drugsNumber = prescriptions!.numberOfDrugsForPrescriptionAtIndex(indexPath.row)
        if drugsNumber == 1
        {
            medString = NSLocalizedString("Medicina", comment: "Sottotitolo riga della prescrizione al singolare")
        }
        else
        {
            medString = NSLocalizedString("Medicine", comment: "Sottotitolo riga della prescrizione al plurale")
        }
        
        let notificationNumber = prescriptions!.numberOfNotificationsForPrescriptionAtIndex(indexPath.row)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
