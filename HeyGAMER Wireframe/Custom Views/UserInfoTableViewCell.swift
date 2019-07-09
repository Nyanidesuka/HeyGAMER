//
//  UserInfoTableViewCell.swift
//  HeyGAMER Wireframe
//
//  Created by Haley Jones on 7/8/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var lookingForLabel: UILabel!
    @IBOutlet weak var favoriteGamesLabel: UILabel!
    @IBOutlet weak var favoriteGenresLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
