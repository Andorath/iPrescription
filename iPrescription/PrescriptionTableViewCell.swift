//
//  PrescriptionTableViewCell.swift
//  iPrescription
//
//  Created by Marco on 04/07/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

import UIKit

class PrescriptionTableViewCell: UITableViewCell {
    
    var textField = UITextField()

    override func layoutSubviews()
    {
        
        super.layoutSubviews()
        self.imageView?.frame = CGRectMake(5, 5, 60, 60)
        self.textLabel?.frame = CGRectMake(super.textLabel!.frame.minX - 25, super.textLabel!.frame.minY, super.textLabel!.frame.size.width, super.textLabel!.frame.size.height)
        self.detailTextLabel!.frame = CGRectMake(super.detailTextLabel!.frame.minX - 25, super.detailTextLabel!.frame.minY, super.detailTextLabel!.frame.size.width, super.detailTextLabel!.frame.size.height)
        
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
