//
//  NotifictionsListController.swift
//  iPrescription
//
//  Created by Marco Salafia on 22/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class NotificationsListController: UITableViewController
{
    var notifications: [UILocalNotification]?
    
    override func viewWillAppear(animated: Bool)
    {
        let userInfo = ["currentController" : self]
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNotificationsForDrug(drug: Drug)
    {
        var selectedNotifications = [UILocalNotification]()
        let id = drug.id
        
        if let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
        {
            for notification in scheduledNotifications
            {
                let userInfo = notification.userInfo
                
                if userInfo!["id"] as! String == id
                {
                    selectedNotifications.append(notification)
                }
            }
        }
        
        notifications = selectedNotifications
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: NotificationTableViewCell = tableView.dequeueReusableCellWithIdentifier("my cell", forIndexPath: indexPath) as! NotificationTableViewCell
        
        if let notification = notifications?[indexPath.row]
        {
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            cell.textLabel?.text = timeFormatter.stringFromDate(notification.fireDate!)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE dd MMMM yyyy"
            cell.detailLabel.text = dateFormatter.stringFromDate(notification.fireDate!)
            
            if notification.repeatInterval.rawValue != 0
            {
                cell.detailLabel.text = NSLocalizedString("Inizio: ", comment: "Dettaglio cella elenco notifiche") + cell.detailLabel.text!
                
                switch notification.repeatInterval
                {
                case NSCalendarUnit.Minute:
                    cell.repeatLabel.text = NSLocalizedString("Ogni Minuto", comment: "Ripetizione ogni minuto")
                case NSCalendarUnit.Day:
                    cell.repeatLabel.text = NSLocalizedString("Ogni Giorno", comment: "Ripetizione ogni giorno")
                case NSCalendarUnit.WeekOfYear:
                    cell.repeatLabel.text = NSLocalizedString("Ogni Settimana", comment: "Ripetizione ogni settimana")
                case NSCalendarUnit.Month:
                    cell.repeatLabel.text = NSLocalizedString("Ogni Mese", comment: "Ripetizione ogni mese")
                default:
                    cell.repeatLabel.text = ""
                    
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return notifications!.count
    }
    
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool
    {
        
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            UIApplication.sharedApplication().cancelLocalNotification(notifications![indexPath.row])
            notifications!.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
            NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdatePrescriptionInterface", object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdateDrugsInterface", object: nil)
            goBackForEmptyNotifications()
        }
    }
    
    func goBackForEmptyNotifications()
    {
        if notifications!.isEmpty
        {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //println(notifications[indexPath.row].fireDate)
    }
}