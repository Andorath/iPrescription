//
//  Prescription.swift
//  iPrescription
//
//  Created by Marco Salafia on 08/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation

class Prescription
{
    var nome: String
    var creazione: NSDate
    var medicine: [Drug] = [Drug]()
    
    init(nome: String, creazione: NSDate)
    {
        self.nome = nome
        self.creazione = creazione
    }
    
    convenience init(nome: String)
    {
        self.init(nome: nome, creazione: NSDate())
    }
    
    convenience init(nome: String, drugs: [Drug])
    {
        self.init(nome: nome, creazione: NSDate())
        self.medicine = drugs
    }
    
    convenience init(nome: String, creazione: NSDate, drugs: [Drug])
    {
        self.init(nome: nome, creazione: creazione)
        self.medicine = drugs
    }
}

class Drug
{
    var data_ultima_assunzione: NSDate?
    var dosaggio: String
    var dottore: String
    var durata: String
    var forma: String
    var id: String
    var nome: String
    var note: String
    
    init (name: String, dosage: String, doc: String, period: String, form: String, note: String, id: String, date_last_assumption: NSDate?)
    {
        self.dosaggio = dosage
        self.dottore = doc
        self.durata = period
        self.forma = form
        self.nome = name
        self.note = note
        self.id = id
        self.data_ultima_assunzione = date_last_assumption
    }
    
    convenience init(name: String, dosage: String, doc: String, period: String, form: String, note: String, date_last_assumption: NSDate?)
    {
        let id = NSUUID().UUIDString
        self.init(name: name, dosage: dosage, doc: doc, period: period, form: form, note: note, id: id, date_last_assumption: date_last_assumption)
    }
    
    convenience init(name: String, dosage: String, doc: String, period: String, form: String, note: String)
    {
        let id = NSUUID().UUIDString
        self.init(name: name, dosage: dosage, doc: doc, period: period, form: form, note: note, id: id, date_last_assumption: nil)
    }
    
}