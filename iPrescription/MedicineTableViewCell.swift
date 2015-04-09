//
//  MedicineTableViewCell.swift
//  iPrescription
//
//  Created by Marco on 04/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit

class MedicineTableViewCell: UITableViewCell {

    @IBOutlet var alarmIcon: UIImageView!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.imageView?.frame = CGRectMake(5, 5, 50, 50)
        self.textLabel?.frame = CGRectMake(super.textLabel!.frame.minX - 25, super.textLabel!.frame.minY, super.textLabel!.frame.size.width - 10, super.textLabel!.frame.size.height)
        self.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 22)
        
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
