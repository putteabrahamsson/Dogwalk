//
//  RowTableViewCell.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-28.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class RowTableViewCell: UITableViewCell {
    
    //Image of the dog
    @IBOutlet weak var dogImage: UIImageView!
    
    //Name of the dog
    @IBOutlet weak var dogName: UILabel!
    
    //Walk information
    @IBOutlet weak var member: UILabel!
    @IBOutlet weak var action: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    
    //Location
    @IBOutlet weak var location: UILabel!
    
    //Message
    @IBOutlet weak var message: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
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

}
