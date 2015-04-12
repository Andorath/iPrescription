//
//  NotificationTableViewController.swift
//  iPrescription
//
//  Created by Marco on 21/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATA

import UIKit

class NotificationTableViewController: UITableViewController
{
    var notifications: [UILocalNotification] = [UILocalNotification]()
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: NotificationTableViewCell? = tableView.dequeueReusableCellWithIdentifier("my cell", forIndexPath: indexPath) as? NotificationTableViewCell
        
        /*if cell == nil
        {
            cell = NotificationTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "my cell")
        }*/
        
        var notification = notifications[indexPath.row]
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        cell!.textLabel?.text = timeFormatter.stringFromDate(notification.fireDate!)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE dd MMMM yyyy"
        cell!.detail.text = dateFormatter.stringFromDate(notification.fireDate!)
        
        if notification.repeatInterval != nil
        {
            cell!.detail.text = NSLocalizedString("Inizio: ", comment: "Dettaglio cella elenco notifiche") + cell!.detail.text!
            
            switch notification.repeatInterval
            {
                case NSCalendarUnit.CalendarUnitMinute:
                    cell!.repeat.text = NSLocalizedString("Ogni Minuto", comment: "Ripetizione ogni minuto")
                case NSCalendarUnit.CalendarUnitDay:
                    cell!.repeat.text = NSLocalizedString("Ogni Giorno", comment: "Ripetizione ogni giorno")
                case NSCalendarUnit.CalendarUnitWeekOfYear:
                    cell!.repeat.text = NSLocalizedString("Ogni Settimana", comment: "Ripetizione ogni settimana")
                case NSCalendarUnit.CalendarUnitMonth:
                    cell!.repeat.text = NSLocalizedString("Ogni Mese", comment: "Ripetizione ogni mese")
                default:
                    cell!.repeat.text = ""
                
            }
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return notifications.count
    }
    
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool
    {
        
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            UIApplication.sharedApplication().cancelLocalNotification(notifications[indexPath.row])
            notifications.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Right)
            NSNotificationCenter.defaultCenter().postNotificationName("NSUpdateInterface", object: nil)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //println(notifications[indexPath.row].fireDate)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        var userInfo = ["currentController" : self]
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        super.viewWillAppear(animated)
    }

    override func viewDidLoad()
    {
        
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
