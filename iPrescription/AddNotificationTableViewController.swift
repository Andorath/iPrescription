//
//  AddNotificationTableViewController.swift
//  iPrescription
//
//  Created by Marco on 16/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATO

import UIKit

class AddNotificationTableViewController: UITableViewController
{
    lazy var prescriptionsModel: PrescriptionList = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptionsModel
    
    var currentDrug: Drug?

    var repeatInterval: NSCalendarUnit?
    
    var lastIndexPath = NSIndexPath(forRow: 0, inSection: 1)

    @IBOutlet var selected: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var memoTextView: UITextView!
    
    override func viewDidLoad()
    {
        setDateLabel()
        memoTextView.inputAccessoryView = getDoneToolbar()
        
        super.viewDidLoad()
    }
    
    func setDateLabel()
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        selected.text = dateFormatter.stringFromDate(datePicker.date)
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
    
    func setCurrentDrug(drug: Drug)
    {
        self.currentDrug = drug
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func valueChanged(sender: AnyObject)
    {
        setDateLabel()
    }
    
    @IBAction func donePressed(sender: AnyObject)
    {
        let notification = getNewLocalNotificationWithSound("Opening.m4r")
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getNewLocalNotificationWithSound(sound: String) -> UILocalNotification
    {
        let prescription = prescriptionsModel.getPrescriptionFromDrug(currentDrug!)
        let notification = UILocalNotification()
        notification.fireDate = datePicker.date
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = String(format: NSLocalizedString("Notifica per %@ della prescrizione %@\nMemo: %@",
                                                                  comment: "Messaggio della Local Notification"),
                                        currentDrug!.nome,
                                        prescription.nome,
                                        memoTextView.text)
        
        notification.soundName = sound
        
        var userInfo = [String : String]()
        userInfo["id"] = currentDrug!.id
        userInfo["prescrizione"] = prescription.nome
        userInfo["medicina"] = currentDrug!.nome
        userInfo["memo"] = memoTextView.text
        
        notification.userInfo = userInfo
        
        if let interval = self.repeatInterval
        {
            notification.repeatInterval = interval
        }
        
        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        return notification
    }
    
    
    @IBAction func cancelPressed(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - metodi delegate e datasource tableview
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath?)
    {
        if indexPath!.section == 1
        {
            self.lastIndexPath = indexPath!
            
            switch (indexPath!.row)
            {
                case 1:
                    self.repeatInterval = NSCalendarUnit.Day
                case 2:
                    self.repeatInterval = NSCalendarUnit.WeekOfYear
                case 3:
                    self.repeatInterval = NSCalendarUnit.Month
                default:
                    self.repeatInterval = nil
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
        //TODO: controllare se aggiornare queste istruzioni per la versione 2.0.1
        //let userInfo = ["currentController" : self]
        //NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        super.viewWillAppear(animated)
    }

}
