//
//  MoreViewController.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-25.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import Firebase

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //UserDefaults
    let defaults = UserDefaults.standard
    
    //Arrays
    var sectionName:[String] = ["Information", "Share with your friends", "Account"]
    var buttonArray = [
        ["My group"],
        ["Invite a friend"],
        ["Change password", "Logout"]
    ]
    var imageArray = [
        [UIImage.init(named: "group")],
        [UIImage.init(named: "invite")],
        [UIImage.init(named: "password"), UIImage.init(named: "logout")]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate & datasource
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //Tableview properties
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionName.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath) as! MoreTableViewCell
        
        cell.buttonImage.image = imageArray[indexPath.section][indexPath.row]
        cell.buttonName.text = buttonArray[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = UIColor.init(red: 0/256, green: 253/256, blue: 255/256, alpha: 1)
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            self.performSegue(withIdentifier: "group", sender: self)
        case [1, 0]:
            displayMessageAlertView(title: "Ops!", message: "Will be available soon!", actionTitle: "OK")
        case [2, 0]:
            displayPasswordChangeAlert()
        case [2, 1]:
            logoutUser()
        default:
            break
        }
    }
    
    //Displays a password change alert
    func displayPasswordChangeAlert(){
        //Retrieving the email
        let email = defaults.string(forKey: "email")
        
        //Create an alert view
        let alert = UIAlertController(title: "Change password", message: "We will send a password reset to your email '\(email!)'", preferredStyle: .alert)
        
        //Add reset password button
        alert.addAction(UIAlertAction.init(title: "Reset", style: .default, handler: { (nil) in
            
            Auth.auth().sendPasswordReset(withEmail: email!) { (err) in
                if let err = err{
                    print(err.localizedDescription)
                }
            }
        }))
        
        //Add cancel button
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        //Present alert
        self.present(alert, animated: true)
    }
    
    //Logging out the user
    func logoutUser(){
        //Create an alert
        let alert = UIAlertController.init(title: "Logout", message: "Are you sure that you want to logout?", preferredStyle: .alert)
        
        //Create the logout button & actions
        alert.addAction(UIAlertAction.init(title: "Logout", style: .default, handler: { (_) in
            try! Auth.auth().signOut()
            
            //Removing UserDefaults
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "email")
            defaults.removeObject(forKey: "groupId")
            defaults.removeObject(forKey: "inGroup")
            defaults.removeObject(forKey: "groupName")
            defaults.removeObject(forKey: "firstname")
            
            //Navigates to the first viewController and sets it to the rootVC
            if let storyboard = self.storyboard{
                let vc = storyboard.instantiateViewController(withIdentifier: "SignViewController") as! SignViewController
                
                UIApplication.shared.windows.first?.rootViewController = vc
                
                self.present(vc, animated: true)
            }
        }))
        
        //Create a cancel button
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        //Present the alert
        self.present(alert, animated: true)
    }
}
