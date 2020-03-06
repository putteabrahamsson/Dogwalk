//
//  MembersViewController.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-27.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let databaseHandler = DatabaseHandler.init()
    
    var members:[MemberData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //createArray()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func createArray(){
        databaseHandler.getMembers { (resultArray) in
            self.members = resultArray
            self.tableView.reloadData()
        }
    }
    
    //Tableview properties
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! MembersTableViewCell
        
        cell.firstName.text = members[indexPath.row].firstName
        cell.email.text = members[indexPath.row].email
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  80
    }
    
    
    @IBAction func navigateBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
