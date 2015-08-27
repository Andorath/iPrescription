//
//  RateReminder.swift
//  iPrescription
//
//  Created by Marco Salafia on 27/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit

/// - note: Se una classe contenente un oggetto RateReminder viene istanziata più volte potrebbe succedere
///         che anhe gli oggetti RateReminder vengano istanziati più volte con conseguente perdita dello stato
///         del ciclo di vita dell'applicazione. RateReminder è stata posta Singleton per mantenere sempre la
///         consistenza della Sessione attiva ed evitare che vanga incrementato "numLaunches" al di fuori del
///         primo caricamento dell'applicazione.

class RateReminder: NSObject
{
    static let sharedInstance = RateReminder()
    var newSession = true
    
    var minSessions = 3
    var tryAgainSessions = 6
    
    private override init()
    {
        super.init()
    }
    
/// Questo metodo racchiude l'algoritmo di calcolo per rappresentare nel tempo la richiesta
/// di una recensione per l'applicazione.
/// - requires: E' necessario che questo metodo sia chiamato all'interno del metodo viewDidLoad() del
///             primo UIViewController istanziato dall'applicazione in quanto è quello più
///             corretto per rappresentare l'avvio dell'applicazione.
///             Prestare attenzione nel caso in cui la classee contenente un oggetto rate Reminder
///             venga reistanziato.
    
    func rateMeWithPresenter(presenter: UIViewController)
    {
        if newSession
        {
            newSession = false
            
            let neverRate = NSUserDefaults.standardUserDefaults().boolForKey("neverRate")
            var numLaunches = NSUserDefaults.standardUserDefaults().integerForKey("numLaunches") + 1
            
            //TODO: Rimuovi questo NSLog
            NSLog("Numero di Avvii: \(numLaunches)")
            
            if (!neverRate && (numLaunches == minSessions || numLaunches >= (minSessions + tryAgainSessions + 1)))
            {
                showRateMeAlertWithPresenter(presenter)
                numLaunches = minSessions + 1
            }
            
            NSUserDefaults.standardUserDefaults().setInteger(numLaunches, forKey: "numLaunches")
        }
    }
    
    func showRateMeAlertWithPresenter(presenter: UIViewController)
    {
        let alert = UIAlertController(title: NSLocalizedString("Grazie per usare iPrescription", comment: "Title rate Alert"),
                                      message: NSLocalizedString("Se potessi lasciare una recensione ci aiuteresti a crescere e a rendere iPrescription un prodotto migliore. \nTi ringraziamo infinitamente!",
                                                                 comment: "Messagge of Rate Alert"),
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Recensisci iPrescription", comment: "Recensisci Action"),
                                      style: UIAlertActionStyle.Default){
                                        alertAction in
                                            UIApplication.sharedApplication().openURL(NSURL(string : "https://itunes.apple.com/it/app/iprescription/id918512784?mt=8")!)
                                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
                                            alert.dismissViewControllerAnimated(true, completion: nil)
                                    })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No Grazie", comment: "No Grazie Action"),
                                      style: UIAlertActionStyle.Destructive){ alertAction in
                                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
                                            alert.dismissViewControllerAnimated(true, completion: nil)
                                    })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ricordamelo più tardi", comment: "Try Later Action"),
                                      style: UIAlertActionStyle.Cancel){ alertAction in
                                            alert.dismissViewControllerAnimated(true, completion: nil)
                                    })
        
        presenter.presentViewController(alert, animated: true, completion: nil)
    }
}