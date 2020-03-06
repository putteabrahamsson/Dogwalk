//
//  WalkTableViewCell.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-24.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import TransitionButton

class WalkTableViewCell: UITableViewCell {

    //Textfields
    @IBOutlet weak var dog: UITextField!
    @IBOutlet weak var person: UITextField!
    @IBOutlet weak var action: UITextField!
    @IBOutlet weak var dateTime: UITextField!
    
    //Segment
    @IBOutlet weak var walkSegment: UISegmentedControl!
    
    //Button
    @IBOutlet weak var saveButton: TransitionButton!
    
    //Creating an array of textfields
    var textfieldArray:[UITextField]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Array of all textfields
        textfieldArray = [dog, person, action, dateTime]
        
        //Loop through array and set the right image
        for index in textfieldArray{
            setTextfieldImage(textfield: index)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Add an arrow to textfields
    func setTextfieldImage(textfield: UITextField){
        //Will display the image on the right.
        textfield.rightViewMode = .always
        
        //Create an imageView.
        let imageView = UIImageView();
        
        //Adding an image.
        let image = UIImage(systemName: "arrow.right.circle")
        
        //Sets the size of the imageView.
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.tintColor = UIColor.init(red: 0/256, green: 253/256, blue: 255/256, alpha: 1)
        
        //Adding the image to the imageView.
        imageView.image = image;
        textfield.rightView = imageView;
    }
    
}
