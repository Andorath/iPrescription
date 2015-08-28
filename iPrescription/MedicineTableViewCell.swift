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
        self.imageView?.frame = CGRectMake(5, 5, 60, 60)
        self.textLabel?.frame = CGRectMake(super.textLabel!.frame.minX - 25, super.textLabel!.frame.minY, super.textLabel!.frame.size.width - 10, super.textLabel!.frame.size.height)
        self.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        self.textLabel?.textColor = UIColor(red: 35.0/255.0, green: 146.0/255.0, blue: 199.0/255.0, alpha: 1)
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.textLabel?.minimumScaleFactor = 0.6
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
