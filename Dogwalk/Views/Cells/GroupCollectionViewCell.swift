//
//  GroupCollectionViewCell.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-25.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var dogImage: UIImageView!
    @IBOutlet weak var dogName: UILabel!
    
    //Strings
    var documentId: String!
    
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

}
