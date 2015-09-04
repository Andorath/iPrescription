//
//  AddNotificationTableViewController.swift
//  iPrescription
//
//  Created by Marco on 16/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATO

import UIKit

class AddNotificationTableViewControllerOLD: UITableViewController {
    
    var medicina: String?
    var prescription: String?
    var uuid: String?
    var repeatInterval: NSCalendarUnit?
    
    var lastIndexPath = NSIndexPath(forRow: 0, inSection: 1)
    
    @IBOutlet var selected: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var memoTextView: UITextView!
    
    
    @IBAction func valueChanged(sender: AnyObject)
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        selected.text = dateFormatter.stringFromDate(datePicker.date)
    }
    
    @IBAction func donePressed(sender: AnyObject)
    {
        let notification = UILocalNotification()
        notification.fireDate = datePicker.date
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = String(format: NSLocalizedString("Notifica per %@ della prescrizione %@\nMemo: %@", comment: "Messaggio della Local Notification"), medicina!, prescription!, memoTextView.text)
        
        //notification.soundName = UILocalNotificationDefaultSoundName
        notification.soundName = "Opening.m4r"
        
        var userInfo = [String : String]()
        userInfo["id"] = uuid!
        userInfo["prescrizione"] = prescription!
        userInfo["medicina"] = medicina!
        userInfo["memo"] = memoTextView.text
        
        notification.userInfo = userInfo
        
        if let interval = self.repeatInterval
        {
            notification.repeatInterval = interval
        }
        
        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func cancelPressed(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //funzioni delegate e datasource tableview
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath?)
    {
        if indexPath!.section == 1
        {
            self.lastIndexPath = indexPath!
            
            switch (indexPath!.row)
            {
            case 1:
                self.repeatInterval = NSCalendarUnit.Day
                print("Hai scelto Ogni Giorno")
            case 2:
                self.repeatInterval = NSCalendarUnit.WeekOfYear
                print("Hai scelto Ogni Settimana")
            case 3:
                self.repeatInterval = NSCalendarUnit.Month
                print("Hai scelto Ogni Mese")
            default:
                self.repeatInterval = nil
                print("Hai scelto Nessuna")
            }
            
            tableView.reloadData()
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell
        
        if(indexPath.compare(self.lastIndexPath) == NSComparisonResult.OrderedSame)
        {
            cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else
        {
            cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func dismissKeyboard()
    {
        if memoTextView.isFirstResponder()
        {
            memoTextView.resignFirstResponder()
            
        }
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        let userInfo = ["currentController" : self]
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad()
    {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        selected.text = dateFormatter.stringFromDate(datePicker.date)
        
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        toolBar.barStyle = UIBarStyle.Default
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Fine", comment: "Done per toolbar"), style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
        doneButton.tintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 1)
        let arrayItem = [doneButton]
        toolBar.items = arrayItem
        
        memoTextView.inputAccessoryView = toolBar
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Funzioni di diagnostica del developer
    
    
    @IBAction func stampaNumeroNotifiche(sender: AnyObject)
    {
        //Possibile errore dovuto al ritorno di nil in assenza di notifiche
        var numberOfNotfication = UIApplication.sharedApplication().scheduledLocalNotifications!.count
        
        var alert = UIAlertController(title: "Diagnostica Developer", message: "Ci sono \(numberOfNotfication) notifiche attive per l'App", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Destructive, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteAllNotifications(sender: AnyObject)
    {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        print("Tutte le norifche locali cancellate!")
    }
    
}
