//
//  InfoViewController.swift
//  iPrescription
//
//  Created by Marco on 29/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATA

import UIKit

class InfoViewController: PageViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var gestisciPrescrizioni: UITextView!
    @IBOutlet weak var gestisciFarmaci: UITextView!
    @IBOutlet weak var gestisciNotifiche: UITextView!
    @IBOutlet weak var designText: UITextView!
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.pageIndex = 0
    }
    
    override func viewWillAppear(animated: Bool)
    {
        var userInfo = ["currentController" : self]
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateCurrentControllerNotification", object: nil, userInfo: userInfo)
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gestisciPrescrizioni.text = NSLocalizedString("Gestisci i tuoi farmaci in Prescrizioni. Usa i nomi più consoni per raggrupparli, come ad esempio Allergia, Terapia Antibiotica o Medicine di Mario.",comment: "Testo della text view 1 Info")
        gestisciFarmaci.text = NSLocalizedString("Aggiungi i tuoi farmaci nell'apposita Prescrizione da te creata. Gestisci tutti i dettagli fondamentali come la posologia o le istruzioni del medico.", comment: "Testo della text view 2 Info")
        gestisciNotifiche.text = NSLocalizedString("Crea e gestisci le notifiche per i tuoi farmaci in pochi passi. Gestisci la tua terapia in modo da rispettare correttamente i tempi di assunzione. Gestire le notifiche, cancellarle o crearne di nuove è davvero un gioco da ragazzi.", comment: "Testo della text view 3 Info")
        designText.text = NSLocalizedString("Con un design minimale, pulito e intuitivo, iPrescription semplificherà notevolmente la gestione delle tue terapie. Troverai la sua interfaccia familiare in quanto lo scopo di iPrescription è di porsi come una estensione di iOS", comment: "Testo della text view 4 Info")
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
