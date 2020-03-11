//
//  NotificationViewController.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-26.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import WLEmptyState

class NotificationViewController: UIViewController, WLEmptyStateDataSource {
   
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Database
    var dataArray:[NotificationHolder] = []
    let databaseHandler = DatabaseHandler.init()
    
    //Variables
    var newInvite: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Retrieving group name from UserDefaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "groupName")
        
        //Creating the array
        createArray()
        
        //Delegate & Datasource
        tableView.emptyStateDataSource = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //Display image and text if no data in tableview exists
    func imageForEmptyDataSet() -> UIImage? {
        return UIImage(named: "notification_big")
    }
    
    func titleForEmptyDataSet() -> NSAttributedString {
        let title = NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)])
        return title
    }
    
    func descriptionForEmptyDataSet() -> NSAttributedString {
        let title = NSAttributedString(string: "You don't have any new notifications", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)])
        return title
    }
    
    //Get data from database
    func createArray(){
        getNotification()
        
        databaseHandler.getNotificationData { (arrayResult) in
            self.dataArray = arrayResult
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }
    }
    
    //Check if there is any new invites
    func getNotification(){
        databaseHandler.getNotification { (result) in
            if result > 0{
                self.newInvite = result
            }
            else{
                self.newInvite = 0
            }
        }
    }
    
    //MARK: - Accept / Deny group
    //Accepting group invite
    @objc func acceptGroup(){
        databaseHandler.acceptGroupInvite(accept: true){
            self.dataArray = []
            self.createArray()
            self.removeTabBarBadge()
        }
    }
    
    //Denying group invite
    @objc func denyGroup(){
        databaseHandler.acceptGroupInvite(accept: false){
            self.dataArray = []
            self.createArray()
            self.removeTabBarBadge()
        }
    }
    
    //Remove tabbar if accepted / denied
    func removeTabBarBadge(){
        if let tabItems = self.tabBarController?.tabBar.items{
            let tabItem = tabItems[2]
            tabItem.badgeValue = nil
        }
    }
}

//MARK: - Tableview properties
extension NotificationViewController: UITableViewDelegate, UITableViewDataSource{
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           if newInvite == 0 {
               return 0
           }else{
               return 1
           }
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: Cells.notificationCell.rawValue, for: indexPath) as! NotificationTableViewCell
           
           //Set cell if dataArray is more than 0
           if dataArray.count > 0{
               let data = dataArray[indexPath.row]
               cell.setCell(holder: data)
           }
           
           //Add targets for tableview buttons
           cell.acceptGroup.addTarget(self, action: #selector(acceptGroup), for: .touchUpInside)
           cell.declineGroup.addTarget(self, action: #selector(denyGroup), for: .touchUpInside)
           
           return cell
       }
       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 130
       }
}
