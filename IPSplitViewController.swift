//
//  IPSplitViewController.swift
//  iPrescription
//
//  Created by Marco on 31/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit

class IPSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        var detailNavigationController = (viewControllers[1] as! IPDetailNavigationController)
        self.delegate = detailNavigationController
        
        //Notifiche
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDelegate:", name: "MSUpdateDelegate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showDetail:", name: "MSShowDetail", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Handler
    
    func showDetail(notification: NSNotification)
    {
        var oldDetail = (self.viewControllers[1] as! UINavigationController).viewControllers[0] as! UIViewController
        //(notification.object as UIViewController).navigationItem.leftBarButtonItem = oldDetail.navigationItem.leftBarButtonItem
        var navigation = self.viewControllers[1] as! IPDetailNavigationController
        navigation.setViewControllers([notification.object!], animated: true)
    }
}
