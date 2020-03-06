//
//  HistoryViewController.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-25.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import WLEmptyState

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WLEmptyStateDataSource {

    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Sections
    var sections:[String] = ["Today", "Older"]
    
    //Array thats holding our data
    var dataArray:[HistoryData] = []
    var todayData:[HistoryData] = []
    
    //Database handler
    let databaseHandler = DatabaseHandler.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Calling the function to create the arrays
        createArray()
        
        //tableView.emptyStateDataSource = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //If no history were found
    func imageForEmptyDataSet() -> UIImage? {
        return UIImage(named: "history_big")
    }
    
    func titleForEmptyDataSet() -> NSAttributedString {
        let title = NSAttributedString(string: "No data could be found", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)])
        return title
    }
    
    func descriptionForEmptyDataSet() -> NSAttributedString {
        let title = NSAttributedString(string: "You have to add a new walk to be able to see it in the history list.", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)])
        return title
    }
    
    //Retrieve walks from Firebase
    func createArray(){
        databaseHandler.getWalks { (resultArray, todayArray) in
            self.dataArray = resultArray
            self.todayData = todayArray
            
            //Sortings the arrays by dateTime
            self.dataArray = self.dataArray.sorted() { $0.dateTime > $1.dateTime }
            self.todayData = self.todayData.sorted() { $0.dateTime > $1.dateTime }
            
            //Reloads the tableview
            self.tableView.reloadData()
        }
    }
    
    //Tableview properties
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return todayData.count
        }
        else{
            return dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        if indexPath.section == 0{
            //Prior the download of the images
            let dogImagePath = todayData[indexPath.row].dogImage
            //cell.dogImage.downloaded(from: dogImagePath)
            cell.dogImage.downloadImages(from: dogImagePath as NSString)
            
            //Change the format of dateTime
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "sv")
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let date = dateFormatter.date(from:todayData[indexPath.row].dateTime)
            
            //Convert the date back into a string
            dateFormatter.dateFormat = "HH:mm"
            let time = dateFormatter.string(from: date!)
            
            //Set the cells
            cell.dogName.text = todayData[indexPath.row].dog
            cell.time.text = time
        }
        else{
            //Prior the download of the images
            let dogImagePath = dataArray[indexPath.row].dogImage
            //cell.dogImage.downloaded(from: dogImagePath)
            cell.dogImage.downloadImages(from: dogImagePath as NSString)
            
            //Change the format of dateTime
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "sv")
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let date = dateFormatter.date(from:dataArray[indexPath.row].dateTime)
            
            //Convert date back into a string
            dateFormatter.dateFormat = "HH:mm"
            let time = dateFormatter.string(from: date!)
            
            //Set the cells
            cell.dogName.text = dataArray[indexPath.row].dog
            cell.time.text = time
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.init(red: 0/256, green: 253/256, blue: 255/256, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Start the transformation at -400 in x-axis
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -400, -20, 0)
        
        //Append the cell transform to rotationTransform
        cell.layer.transform = rotationTransform
        
        //Set the transformation at center with duration
        UIView.animate(withDuration: 0.75) {
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Navigate to RowViewController
        self.performSegue(withIdentifier: "showRow", sender: self)
    }
    
    //Preparing for the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow{
            let vc = segue.destination as! RowViewController
            
            //Pass the correct data to the RowViewController
            if indexPath.section == 0{
                vc.dataArray = [todayData[indexPath.row]]
            }
            else{
                vc.dataArray = [dataArray[indexPath.row]]
            }
        }
    }
}
