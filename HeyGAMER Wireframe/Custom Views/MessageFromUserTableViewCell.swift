//
//  MessageFromUserTableViewCell.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/16/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class MessageFromUserTableViewCell: UITableViewCell {
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
