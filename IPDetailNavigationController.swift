//
//  IPDetailNavigationController.swift
//  iPrescription
//
//  Created by Marco on 01/08/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit

class IPDetailNavigationController: UINavigationController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //Funzioni delegate
    
    func splitViewController(svc: UISplitViewController, willHideViewController aViewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController pc: UIPopoverController)
    {
        barButtonItem.title = "sattoh"
        barButtonItem.image = UIImage(named: "menu@2x.png")
        (self.viewControllers[0] ).navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func splitViewController(svc: UISplitViewController, willShowViewController aViewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem)
    {
        (self.viewControllers[0] ).navigationItem.leftBarButtonItem = nil
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
