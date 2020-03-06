//
//  RowViewController.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-28.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class RowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Array thats holding our data
    var dataArray:[HistoryData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //Tableview properties
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rowCell", for: indexPath) as! RowTableViewCell
        
        //Download image data
        let imagePath = dataArray[indexPath.row].dogImage
        cell.dogImage.downloadImages(from: imagePath as NSString)
        //cell.dogImage.downloaded(from: dataArray[indexPath.row].dogImage)
        
        //Get latitude & longitude from dataArray
        let latitude = dataArray[indexPath.row].latitude
        let longitude = dataArray[indexPath.row].longitude
        
        //Check if latitude & longitude is not 0.0
        if latitude != 0.0 || longitude != 0.0{
            //Url for the API
            let locationUrl = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=9e73e77789b74d085856e30d5dda6285&units=metric&lang=se"
            
            //Download location from the API
            ApiHandler.init().getLocation(url: locationUrl) { (locationArray) in
                let city = locationArray[indexPath.row].name
                let country = locationArray[indexPath.row].sys.country
                cell.location.text = "\(city), \(country)"
            }
        }
        else{
            //If no location were found
            cell.location.text = "No location was found.."
        }
        
        //Set cells of other
        cell.dogName.text = dataArray[indexPath.row].dog
        cell.member.text = dataArray[indexPath.row].person
        cell.action.text = dataArray[indexPath.row].action
        cell.dateTime.text = dataArray[indexPath.row].dateTime
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 996
    }
    
    //Closing the current viewcontroller
    @IBAction func navigateBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Share a walk with your friends
    @IBAction func shareWalk(_ sender: Any) {
        displayMessageAlertView(title: "Ops!", message: "Will be available soon!", actionTitle: "OK")
    }
}
