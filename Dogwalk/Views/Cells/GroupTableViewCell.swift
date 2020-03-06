//
//  GroupTableViewCell.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-26.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var buttonName: UILabel!
    @IBOutlet weak var buttonImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
