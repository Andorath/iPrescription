//
//  ChangeDateTableViewController.swift
//  iPrescription
//
//  Created by Marco on 23/09/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATO

import UIKit

class ChangeDateTableViewController: UITableViewController {
    
    @IBOutlet weak var dataAssunzione: UILabel!
    @IBOutlet weak var selettoreData: UIDatePicker!
    
    @IBAction func valueChanged(sender: AnyObject)
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dataAssunzione.text = dateFormatter.stringFromDate(selettoreData.date)
    }
    
    @IBAction func donePressed(sender: AnyObject)
    {
        ((self.navigationController?.presentingViewController as! UINavigationController).topViewController as! DrugDetailController).assumiFarmaco(selettoreData.date)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelPressed(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        let userInfo = ["currentController" : self]
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad()
    {
        self.selettoreData.maximumDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dataAssunzione.text = dateFormatter.stringFromDate(selettoreData.date)
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
