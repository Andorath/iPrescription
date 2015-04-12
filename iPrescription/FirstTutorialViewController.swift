//
//  FirstTutorialViewController.swift
//  iPrescription
//
//  Created by Marco on 07/08/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATA

import UIKit

class FirstTutorialViewController: PageViewController {
    
    @IBOutlet weak var text1: UITextView!
    @IBOutlet weak var text2: UITextView!
    @IBOutlet weak var text3: UITextView!
    @IBOutlet weak var text4: UITextView!
    @IBOutlet weak var text5: UITextView!
    @IBOutlet weak var text6: UITextView!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.pageIndex = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        text1.text = NSLocalizedString("Puoi memorizzare un numero indefinito di Prescrizioni e Medicinali, ma due prescrizioni non possono avere lo stesso nome. I medicinali invece non hanno questa limitazione.", comment: "text 1 guida")
        text2.text = NSLocalizedString("Nella Pagina delle prescrizioni premi il pulsante modifica per entrare in Modalità Modifica. In questa modalità è possibile cancellare le prescrizioni con tutti i medicinali contenuti in esse e le eventuali notifiche attive. Se invece si tocca il nome della prescrizione è possibile cambiarlo con uno nuovo. Per cancellare un medicinale invece basta scorrere la riga corrispondente verso sinistra con il dito.", comment: "text 2 guida")
        text3.text = NSLocalizedString("Nella pagina Dettaglio è possibile consultare tutte le informazioni inserite precedentemente sul farmaco ed eventualmente modificarle. Per poter cambiare le informazioni bisogna premere il pulsante modifica per entrare nella Modalità Modifica. Inoltre nella pagina Dettaglio è possibile controllare la data dell'ultima assunzione del farmaco!", comment: "text 3 guida")
        
        text4.text = NSLocalizedString("Creare degli avvisi per quando prendere una farmaco è un gioco da ragazzi. Premi Aggiungi Notifica in fondo alla pagina Dettaglio e verrai rimandato a una schermata dove creerai un avviso in pochi secondi. Quando hai finito premi Fine per creare la notifica o Cancella per tornare indietro. Premendo Notifiche Attive invece potrai visualizzare tutte le notifiche attive per quel farmaco.", comment: "text 4 guida")
        text5.text = NSLocalizedString("Le notifiche dove hai impostato una ripetizione verranno visualizzate con l'intervallo di ripetizione in rosso alla destra dell'ora e la data in cui inizierai ad assumere il farmaco.", comment: "text 5 guida")
        text6.text = NSLocalizedString("Tutti i farmaci che hanno almeno una notifica attiva sono segnalati con un'icona rossa a forma di sveglia alla destra della riga.", comment: "text 6 guida")

        // Do any additional setup after loading the view.
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
