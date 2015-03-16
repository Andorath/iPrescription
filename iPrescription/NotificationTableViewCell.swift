//
//  NotificationTableViewCell.swift
//  iPrescription
//
//  Created by Marco on 24/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var repeat: UILabel!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.textLabel.frame = CGRectMake(15, 9, 140, 32)
        self.textLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 27)
        self.textLabel.textColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 1)
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
