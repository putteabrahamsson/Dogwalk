//
//  GroupViewController.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-25.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupHeader: UINavigationItem!
    
    //Database
    let databaseHandler = DatabaseHandler.init()
    
    //Variables
    var groupId: String!
    var groupName: String!
    var inGroup: Bool!
    
    //Arrays
    var sectionArray = ["Group", "Edit group"]
    var buttonArray = [
        ["Create a group", "Invite user"],
        ["Add a new dog", "Members"]
    ]
    var dogArray:[DogData] = []
    var members:[MemberData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Retrieve group information
        getGroupInfo()
        
        //Delegate & datasource
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createArray()
    }
    
    func getGroupInfo(){
        //UserDefaults
        let defaults = UserDefaults.standard
        inGroup = defaults.bool(forKey: "inGroup")
        groupId = defaults.string(forKey: "groupId")
        
        //Get groupname from Firebase
        databaseHandler.getGroupName { (name) in
            self.groupName = name
            self.groupHeader.title = self.groupName
        }
    }
    
    //Retrieve the dogs from Firebase
    func createArray(){
        databaseHandler.getDogs { (resultArray) in
            self.dogArray = []
            self.dogArray = resultArray
            
            //Sort dogArray by name
            self.dogArray = self.dogArray.sorted() { $0.dogName < $1.dogName }
            
            //Reload collectionView
            self.collectionView.reloadData()
        }
        
        //Retrieve all members
        databaseHandler.getMembers { (resultArray) in
            self.members = resultArray
        }
    }
    
    /* Collectionview properties */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dogArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupCell", for: indexPath) as! GroupCollectionViewCell
        
        //Sets the cell
        let imagePath = dogArray[indexPath.row].dogImageUrl
        cell.dogImage.downloadImages(from: imagePath as NSString)
        
        cell.dogName.text = dogArray[indexPath.row].dogName
        cell.documentId = dogArray[indexPath.row].documentId
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        removeDogAlert(indexPath: indexPath)
    }
    
    /* Tableview properties */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupTableCell", for: indexPath) as! GroupTableViewCell
        
        //Sets the cell
        //cell.buttonImage.image = <-- FIX
        cell.buttonName.text = buttonArray[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if inGroup{
            if indexPath == [0, 0]{
                return 0 //Hide create group button
            }
        }
        else if !inGroup{
            if indexPath == [0, 1]{
                return 0 //Hide invite button
            }
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.init(red: 0/256, green: 253/256, blue: 255/256, alpha: 1)
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            createGroup()
        case [0, 1]:
            inviteUser()
        case [1, 0]:
            if inGroup{
                self.performSegue(withIdentifier: "addDog", sender: self)
            }
            else{
                requiredGroup()
            }
        case [1, 1]:
            if inGroup{
                self.performSegue(withIdentifier: "checkMembers", sender: self)
            }
            else{
                requiredGroup()
            }
    
        default:
            print("None")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkMembers"{
            let vc = segue.destination as! MembersViewController
            vc.members = members
        }
    }
    
    //User is required to be in a group to add dogs, members
    func requiredGroup(){
        displayMessageAlertView(title: "Ops!", message: "You have to create/join a group first!", actionTitle: "OK")
    }
    
    //Display an alert if user removes a dog.
    func removeDogAlert(indexPath: IndexPath){
        let cell = collectionView.cellForItem(at: indexPath) as! GroupCollectionViewCell
        
        let alert = UIAlertController(title: "Warning!", message: "Are you sure that you want to remove \(cell.dogName.text ?? "")?", preferredStyle: .alert)
        
        //Remove button
        alert.addAction(UIAlertAction.init(title: "Remove", style: .default, handler: { (alert) in
            
            //Removing the dog from Firebase
            self.databaseHandler.removeDog(dogPath: cell.documentId) {
                self.createArray()
                self.displayMessageAlertView(title: "Succeded", message: "'\(cell.dogName.text ?? "")' was successfully deleted", actionTitle: "OK")
            }
        }))
        
        //Cancel button
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    //Create a new group
    func createGroup(){
        let alert = UIAlertController(title: "Create a group", message: "Name your group", preferredStyle: .alert)

        //Add a textfield to the alert
        alert.addTextField { (textField) in
            textField.placeholder = "Enter a name of the group"
        }

        //Create group button
        alert.addAction(UIAlertAction(title: "Create group", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            //Add group to Firebase
            self.databaseHandler.createGroup(textField: textField!.text!, uuid: self.groupId!)

            //Sets the inGroup variable to true
            self.inGroup = true
            
            //Reload tableview with the new group data
            self.tableView.reloadData()
            
        }))
        
        //Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    //Invite a user to the existing group
    func inviteUser(){
        let alert = UIAlertController(title: "Invite", message: "Invite a new user to your group", preferredStyle: .alert)

        //Enter an email to invite
        alert.addTextField { (textField) in
            textField.placeholder = "Enter the email"
        }

        //Invite button
        alert.addAction(UIAlertAction(title: "Invite", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            //Set textfield as lowercase
            textField?.text = textField?.text?.lowercased()

            //Temp array for holding our member emails
            var temp:[String] = []
            
            //Loop through and append email to temp
            for index in self.members{
                temp.append(index.email.lowercased())
            }
            
            //Check if member is already in group
            if temp.contains(textField!.text!){
                self.displayMessageAlertView(title: "Ops!", message: "That member is already in your group!", actionTitle: "OK")
            }
            else{
                //Member is not in group, invite user.
                self.databaseHandler.getGroupName { (result) in
                    self.databaseHandler.inviteUserToGroup(email: textField!.text!, groupName: result)
                }
            }
            
        }))
        
        //Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    // Close the current viewcontroller
    @IBAction func closeCurrentVc(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
