//
//  DogsTableViewCell.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-27.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import TransitionButton

class DogsTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var dogImage: UIImageView!
    @IBOutlet weak var dogName: UITextField!
    @IBOutlet weak var addDogImage: UIButton!
    @IBOutlet weak var saveDog: TransitionButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //Set properties for the image
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
