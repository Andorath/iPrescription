//
//  DismissSegue.swift
//  iPrescription
//
//  Created by Marco on 29/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue
{
    override func perform()
    {
        var sourceViewController = self.sourceViewController as UIViewController
        sourceViewController.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
}
