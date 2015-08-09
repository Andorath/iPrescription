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
    
    init(nome: String, creazione: NSDate)
    {
        self.nome = nome
        self.creazione = creazione
    }
    
    convenience init(nome: String)
    {
        self.init(nome: nome, creazione: NSDate())
    }
}