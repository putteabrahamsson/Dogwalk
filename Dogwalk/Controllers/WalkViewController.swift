//
//  WalkViewController.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-24.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import TransitionButton
import CoreLocation

class WalkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
   
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Pickerview and  Datepicker
    var pickerView: UIPickerView!
    var datePicker: UIDatePicker!
    
    //DatabaseHandler
    let databaseHandler = DatabaseHandler.init()
    
    //UserDefaults
    let defaults = UserDefaults.standard
    
    //Location manager
    let locationManager = CLLocationManager()
    
    //Arrays to be displayed in alerts
    var dogArray: [DogData] = []
    var memberArray: [MemberData] = []
    var actionArray: [String] = ["Pee", "Poop","Pee & poop", "-----------", "Pee & played", "Pee & running", "Pee, pop & played", "Pee, pop & running", "-----------", "Pee inside", "Pop inside"]
    
    //Variables
    var dog: String?
    var person: String?
    var action: String?
    var dateTime: String?
    var dogImage: String!
    var dogBool = false
    var personBool = false
    var actionBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for permission to use location for coordinates
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        //Delegate & datasource
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //When the view appears.
    override func viewDidAppear(_ animated: Bool) {
        //Create the arrays
        createArrays()
        
        //Get notifications
        getNotification()
        
        //Pre-sets the tableview cell
        setCurrentDateTime()
        person = defaults.string(forKey: "person")
        
        //Reload tableview
        tableView.reloadData()
    }
    
    //Retrieve dogs and members from Firebase
    func createArrays(){
        databaseHandler.getDogs { (resultDogArray) in
            self.dogArray = []
            self.dogArray = resultDogArray
        }
        
        databaseHandler.getMembers { (resultMemberArray) in
            self.memberArray = []
            self.memberArray = resultMemberArray
        }
    }
    
    //Checking for new notifications in Firebase
    func getNotification(){
        databaseHandler.getNotification { (result) in
            
            //If result is > 0, set the tabItem badge.
            if result > 0{
                if let tabItems = self.tabBarController?.tabBar.items{
                    let tabItem = tabItems[2]
                    tabItem.badgeValue = "new"
                }
            }
        }
    }
    
    //Retrieve the current date.
    func setCurrentDateTime(){
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateTime = formatter.string(from: self.datePicker.date)
    }

    //Tableview properties
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogwalkCell", for: indexPath) as! WalkTableViewCell
        
        //Set cells
        cell.dog.text = dog
        cell.person.text = person
        cell.action.text = action
        cell.dateTime.text = dateTime
        
        //Rounded buttons
        cell.saveButton.layer.cornerRadius = 5.0
        
        //Add target for textfields
        cell.dog.addTarget(self, action: #selector(setDog(textfield:)), for: .editingDidBegin)
        cell.person.addTarget(self, action: #selector(setPerson(textfield:)), for: .editingDidBegin)
        cell.action.addTarget(self, action: #selector(setAction(textfield:)), for: .editingDidBegin)
        cell.dateTime.addTarget(self, action: #selector(setDateTime(textfield:)), for: .editingDidBegin)
        
        //Add target for save button.
        cell.saveButton.addTarget(self, action: #selector(saveWalk), for: .touchUpInside)
        
        return cell
    }
            
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 650
    }
    
    //Set data for textfields (Tableview targets)
    @objc func setDog(textfield: UITextField){
        setTextfieldAsView(textfield: textfield)
        
        dogBool = true
        createAlertWithPickerView(title: "Pick a dog")
    }
    
    @objc func setPerson(textfield: UITextField){
        setTextfieldAsView(textfield: textfield)
        
        personBool = true
        createAlertWithPickerView(title: "Pick a person")
    }
    
    @objc func setAction(textfield: UITextField){
        setTextfieldAsView(textfield: textfield)
        
        actionBool = true
        createAlertWithPickerView(title: "Pick an action")
    }
    
    @objc func setDateTime(textfield: UITextField){
        setTextfieldAsView(textfield: textfield)
        
        createAlertWithDatePicker()
    }
    
    //Create an alert with a pickerview
    func createAlertWithPickerView(title: String){
        
        //Sets ViewController with size
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        
        //Sets the pickerview size
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        
        //Delegate & datasource
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //Add pickerview to the viewController
        vc.view.addSubview(pickerView)
        
        //Create an alert
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
        //Cancel button
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
            self.dogBool = false
            self.personBool = false
            self.actionBool = false
        }))
        
        //Done button
        alert.addAction(UIAlertAction.init(title: "Done", style: .default, handler: { (action) in
            self.saveDataToTableView()
            
            self.dogBool = false
            self.personBool = false
            self.actionBool = false
            
            self.tableView.reloadData()
        }))
        
        //Adding the pickerview to alert
        alert.setValue(vc, forKey: "contentViewController")
        
        self.present(alert, animated: true)
    }
    
    //Create an alert with a datepicker
    func createAlertWithDatePicker(){
        
        //Sets ViewController with size
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        
        //Sets the datePicker locale to Swedish time.
        datePicker.locale = Locale.init(identifier: "Swedish")
        
        //Adding the datePicker to ViewController
        vc.view.addSubview(datePicker)
        
        //Create an alert.
        let alert = UIAlertController(title: "Choose date", message: "", preferredStyle: .alert)
        
        //Cancel button
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        //Done button
        alert.addAction(UIAlertAction.init(title: "Done", style: .default, handler: { (action) in
            //Convert date to string.
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            self.dateTime = formatter.string(from: self.datePicker.date)
            
            //Reload tableview.
            self.tableView.reloadData()
        }))
        
        //Adding datePicker to the alert.
        alert.setValue(vc, forKey: "contentViewController")
        
        self.present(alert, animated: true)
    }
    
    //Make textfields non-writeable
    func setTextfieldAsView(textfield: UITextField){
        textfield.inputView = UIView()
        textfield.endEditing(true)
    }
    
    //Set strings from pickerview
    func saveDataToTableView(){
        let x = self.pickerView.selectedRow(inComponent: 0)
        
        if dogBool{
            dog = self.dogArray[x].dogName
        }
        else if personBool{
            person = self.memberArray[x].firstName
            
            //Save person in userdefaults
            defaults.set(person!, forKey: "person")
            defaults.synchronize()
        }
        else if actionBool{
            action = self.actionArray[x]
        }
    }
    
    //PickerView properties
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if dogBool{
            return dogArray.count
        }
        else if personBool{
            return memberArray.count
        }
        else if actionBool{
            return actionArray.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if dogBool{
            dogImage = dogArray[row].dogImageUrl
            return dogArray[row].dogName
        }
        else if personBool{
            return memberArray[row].firstName
        }
        else if actionBool{
            return actionArray[row]
        }
        return ""
    }
    
    //Save a new walk
    @objc func saveWalk(){
        let cell = tableView.cellForRow(at: [0, 0]) as! WalkTableViewCell
        
        //Check if any string are empty
        if cell.dog.text!.isEmpty || cell.person.text!.isEmpty || cell.action.text!.isEmpty || cell.dateTime.text!.isEmpty{
            displayMessageAlertView(title: "Ops!", message: "You have to enter all fields!", actionTitle: "OK")
        }
        else{
            //Start the button animation
            cell.saveButton.startAnimation()
            
            //If walkSegment is equal to "Yes"
            if cell.walkSegment.selectedSegmentIndex == 0 {
                onSavingRow {}
            }
            else{
                onSavingRow {
                    self.tabBarController?.selectedIndex = 1
                }
            }
        }
    }
    
    //Saving the walk to the database
    func onSavingRow(completed: @escaping () -> ()){
        
        //Longitude and latitude
        var longitude: Double?
        var latitude: Double?

        //Check if location services are enabled.
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            
            //Check authorization status
            switch CLLocationManager.authorizationStatus(){
            case .notDetermined, .restricted, .denied: //User has denied, restricted or not determined
                break
            case .authorizedAlways, .authorizedWhenInUse: //User has granted the permission to use
                
                //Get current coordinates
                guard let location: CLLocationCoordinate2D = locationManager.location?.coordinate else{
                    return
                }
                
                //Sets the longitude & latitude
                longitude = location.longitude
                latitude = location.latitude
            @unknown default:
                print("Unknown case occured")
            }
        }
        
        //Getting the cell, indexPath will always remain [0, 0]
        let cell = tableView.cellForRow(at: [0, 0]) as! WalkTableViewCell
        
        //Insert data into Firebase
        self.databaseHandler.saveNewWalk(dog: self.dog!, person: self.person!, action: self.action!, date: self.dateTime!, dogImage: dogImage, longitude: longitude ?? 0.0, latitude: latitude ??  0.0 ){
            
            //Stop the button animation
            cell.saveButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.2) {
                
                //Clearing the strings
                self.dog = ""
                self.action = ""
                
                //Reloading the tableview
                self.tableView.reloadData()
                
                //Completion block for staying / navigating
                completed()
            }
        }
    }
    
    //Will navigate to the mapView for creating a walking route.
    @IBAction func mapButtonTapped(_ sender: Any) {
        displayMessageAlertView(title: "Ops!", message: "Will be available soon!", actionTitle: "OK")
    }
    
    //Add an extra note for your walk.
    @IBAction func walkMessageTapped(_ sender: Any) {
        displayMessageAlertView(title: "Ops!", message: "Will be available soon!", actionTitle: "OK")
    }
}
