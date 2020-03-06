//
//  NotificationTableViewCell.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-26.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var acceptGroup: UIButton!
    @IBOutlet weak var declineGroup: UIButton!
    @IBOutlet weak var groupName: UILabel!
    
    //Strings
    var groupId: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Set the cell data
    func setCell(holder: NotificationHolder){
        groupName.text = holder.groupName
        groupId = holder.groupId
    }

}
