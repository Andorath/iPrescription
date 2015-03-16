//
//  IPDetailTableViewController.swift
//  iPrescription
//
//  Created by Marco on 01/08/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit

class IPDetailTableViewController: UITableViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Questa linea di codice è fondamentale per eliminare un artefatto del backbutton drante la transizione
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationController!.setToolbarHidden(false, animated: true)
    }
    
    //Funzioni delegate
    
    func splitViewController(svc: UISplitViewController!, willHideViewController aViewController: UIViewController!, withBarButtonItem barButtonItem: UIBarButtonItem!, forPopoverController pc: UIPopoverController!)
    {
        barButtonItem.title = "sattoh"
        barButtonItem.image = UIImage(named: "menu@2x.png")
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func splitViewController(svc: UISplitViewController!, willShowViewController aViewController: UIViewController!, invalidatingBarButtonItem barButtonItem: UIBarButtonItem!)
    {
        self.navigationItem.leftBarButtonItem = nil
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
