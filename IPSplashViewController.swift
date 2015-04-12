//
//  IPSplashViewController.swift
//  iPrescription
//
//  Created by Marco on 31/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit

class IPSplashViewController: UIViewController, UISplitViewControllerDelegate {
    
    
    @IBOutlet weak var benvenutoLabel: UILabel!
    @IBOutlet weak var splashLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Questa linea di codice è fondamentale per eliminare un artefatto del backbutton drante la transizione
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        var blurredBackgroundView = UIVisualEffectView(effect: blurEffect)
        blurredBackgroundView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.contentView.frame = blurredBackgroundView.frame
        
        self.view.addSubview(blurredBackgroundView)
        
        
        var vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurredBackgroundView.effect as! UIBlurEffect)
        var vibrantLabelContainerView = UIVisualEffectView(effect: vibrancyEffect)
        vibrantLabelContainerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        vibrantLabelContainerView.frame = self.view.bounds
        
        blurredBackgroundView.contentView.addSubview(vibrantLabelContainerView)
        vibrantLabelContainerView.contentView.addSubview(benvenutoLabel)
        vibrantLabelContainerView.contentView.addSubview(splashLabel)
        
        //Codice della toolbar
        self.navigationController!.setToolbarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
