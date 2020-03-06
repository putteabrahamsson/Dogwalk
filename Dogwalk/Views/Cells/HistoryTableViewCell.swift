//
//  HistoryTableViewCell.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-25.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var dogImage: UIImageView!
    @IBOutlet weak var dogName: UILabel!
    @IBOutlet weak var time: UILabel!
    
    //Strings
    var dogImagePath: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //Set properties for dogImage
        dogImage.layer.borderWidth = 1
        dogImage.layer.masksToBounds = false
        dogImage.layer.borderColor = UIColor.black.cgColor
        dogImage.layer.cornerRadius = dogImage.frame.height/2
        dogImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Set the cell of the tableview
    func setCell(historyData: HistoryData){
        dogImagePath = historyData.dogImage
        dogName.text = historyData.dog
        time.text = historyData.dateTime
    }

}
