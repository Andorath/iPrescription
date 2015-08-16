//
//  DrugDetailController.swift
//  iPrescription
//
//  Created by Marco Salafia on 17/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class DrugDetailController: UITableViewController
{
    var currentDrug: Drug?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastAssumptionLabel: UILabel!
    @IBOutlet weak var formTextField: UITextField!
    @IBOutlet weak var dosageTextField: UITextField!
    @IBOutlet weak var periodTextField: UITextField!
    @IBOutlet weak var doctorTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updateFieldsFromCurrentDrug()
    }
    
    func updateFieldsFromCurrentDrug()
    {
        nameTextField.text = currentDrug?.nome
        
        if let date = currentDrug?.data_ultima_assunzione
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE dd MMMM hh:mm a"
            lastAssumptionLabel.text = dateFormatter.stringFromDate(date)
        }
        else
        {
            lastAssumptionLabel.text = ""
        }
        
        formTextField.text = currentDrug!.forma
        dosageTextField.text = currentDrug!.dosaggio
        periodTextField.text = currentDrug!.durata
        doctorTextField.text = currentDrug!.dottore
        noteTextView.text = currentDrug!.note
    }
    
    func setCurrentDrug(drug: Drug)
    {
        self.currentDrug = drug
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
