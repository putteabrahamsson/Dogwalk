//
//  DogsViewController.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-27.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import Firebase
import TransitionButton

class DogsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    //The iamge
    var imageArray:[UIImage] = []
    
    //Database
    let databaseHandler = DatabaseHandler.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate & datasource
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //Display the image library
    @objc func addImage(){
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
                
        self.present(image, animated: true)
    }
    
    //Selected image from library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //Check if image is valid
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            
            //Clear the array and append the new image
            imageArray = []
            tempImageView.image = image
            imageArray.append(tempImageView.image!)
            
            //Reload tableview to display the image
            self.tableView.reloadData()
        }
        
        //Closing the image library
        self.dismiss(animated: true, completion: nil)
    }
    
    //Save the dog in Firebase
    @objc func saveDog(){
        //Retrieving the button
        let cell = tableView.cellForRow(at: [0, 0]) as! DogsTableViewCell
        
        //Starts the animation
        cell.saveDog.startAnimation()
        
        //If image does exists in the imageArray
        if imageArray.count > 0 {
            
            //Create a unique ID for the image name
            let imageName = UUID().uuidString
            let imageReference = Storage.storage().reference().child(imageName)
            
            //Validate the image
            if let uploadData = self.tempImageView.image!.jpegData(compressionQuality: 0.5){
                
                //Sets the file as .jpeg
                let metaDataForImage = StorageMetadata()
                metaDataForImage.contentType = "image/jpeg"
                
                //Add the data to Firebase
                imageReference.putData(uploadData, metadata: metaDataForImage) { (meta, err) in
                    if let err = err{
                        print(err.localizedDescription)
                    }
                    else{
                        //Retrieving the image URL
                        imageReference.downloadURL { (url, err) in
                            if let err = err{
                                print(err.localizedDescription)
                            }
                            else{
                                //Inserts the image path into Firebase
                                let urlString = url?.absoluteString
                                self.insertDogIntoFirebase(url: urlString)
                            }
                        }
                    }
                }
            }
        }
        else{
            //If no image were added, use original
            let noImgUrl = "https://firebasestorage.googleapis.com/v0/b/dogwalk-new.appspot.com/o/dog_face.png?alt=media&token=b52e7d80-e972-4c37-94bf-17943b8de8ab"
            self.insertDogIntoFirebase(url: noImgUrl)
        }
    }
    
    //Inserting the completed dog into Firebase
    func insertDogIntoFirebase(url: String!){
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! DogsTableViewCell
        
        databaseHandler.addDogToGroup(dogName: cell.dogName.text!, url: url){
            cell.saveDog.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //Hide keyboard if screen is tapped
    @IBAction func onScreenTapped(_ sender: Any) {
        let cell = tableView.cellForRow(at: [0, 0]) as! DogsTableViewCell
        cell.dogName.resignFirstResponder()
    }
    
    //Navigate back to previous viewcontroller
    @IBAction func navigateBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Tableview properties
extension DogsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.dogCell.rawValue, for: indexPath) as! DogsTableViewCell
         
        cell.saveDog.layer.cornerRadius = 5.0
        cell.dogName.delegate = self
        
        //Display image if imageArray is not empty.
        if imageArray.count > 0 {
            cell.dogImage.image = imageArray[0]
        }
        
        //Targets for the buttons
        cell.addDogImage.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        cell.saveDog.addTarget(self, action: #selector(saveDog), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 670
    }
}
