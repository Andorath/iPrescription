//
//  Extensions.swift
//  iPrescription
//
//  Created by Marco Salafia on 28/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit

extension UILocalNotification
{
    func posponeNotification(notification: UILocalNotification, addingTimeInterval ti: NSTimeInterval)
    {
        notification.fireDate = notification.fireDate?.dateByAddingTimeInterval(ti)
        notification.repeatInterval = NSCalendarUnit(rawValue: 0)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdatePrescriptionInterface", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("MGSUpdateDrugsInterface", object: nil)
    }
}