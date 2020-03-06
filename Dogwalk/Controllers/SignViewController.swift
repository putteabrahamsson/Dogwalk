//
//  SignViewController.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-24.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import Firebase
import TransitionButton

class SignViewController: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var actionButton: TransitionButton!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var headerImage: UIImageView!
    
    //Extra for registration
    @IBOutlet weak var firstNameStack: UIStackView!
    @IBOutlet weak var firstName: UITextField!
    
    //Database
    var databaseHandler = DatabaseHandler.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate for textfields
        email.delegate = self
        password.delegate = self
        firstName.delegate = self
    }
    
    //When the view appear
    override func viewDidAppear(_ animated: Bool) {
        //Check if user is already logged in
        if Auth.auth().currentUser?.email != nil{
             self.performSegue(withIdentifier: "toMainVc", sender: self)
        }
        
        //Will display the animation
        displayAnimation()
        
        //Set the corner radius for button
        setCornerRadiusForButton()
    }
    
    //Displaying the animation on load
    func displayAnimation(){
        //Height of image
        let height = headerImage.frame.size.height
        //Animation
        let transform = CATransform3DTranslate(CATransform3DIdentity, 0, -height, 0)
        
        headerImage.layer.transform = transform
        
        UIView.animate(withDuration: 1.0) {
            self.headerImage.layer.transform = CATransform3DIdentity
        }
    }

    //On button click
    @IBAction func actionButton(_ sender: Any) {
        //Start the animation of circular button
        actionButton.startAnimation()
        
        //Login / register depending on selected segment index.
        if segment.selectedSegmentIndex == 0{
            handleLogin()
        }
        else{
            handleRegister()
        }
    }
    
    //If the user signs in
    func handleLogin(){
        //Set lowercased
        email.text = email.text?.lowercased()
        
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (result, err) in
            if let err = err{
                print("Error logging in:", err.localizedDescription)
                //Display alert if sign-in failed
                self.displayMessageAlertView(title: "Ops!", message: "Wrong username / password", actionTitle: "OK")
                self.stopAnimateButton()
            }
            else{
                //Retrieve data if sign-in succeded.
                self.databaseHandler.retrieveData(email: self.email.text!){
                    self.stopAnimateButton()
                    
                    //Navigate to the main screen.
                    self.performSegue(withIdentifier: "toMainVc", sender: self)
                }
            }
        }
    }
    
    //If the user signs up
    func handleRegister(){
        //Set email as lowercased
        email.text = email.text?.lowercased()
        
        //If password is weak
        if password.text!.count < 6{
            //Display alert if password contains less than 6 characters.
            displayMessageAlertView(title: "Bad password", message: "Your password must contain atleast 6 characters.", actionTitle: "OK")
            self.stopAnimateButton()
        }
        else{
            //Create the user
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (result, err) in
                if let err = err{
                    print("Error Message:", err.localizedDescription)
                    
                    //Display alert if account already exists
                    self.displayMessageAlertView(title: "Ops!", message: "The account already exists!", actionTitle: "OK")
                    self.stopAnimateButton()
                }
                else{
                    //Add user details to Firebase
                    self.databaseHandler.createAccount(email: self.email.text!, firstName: self.firstName.text!){
                        self.stopAnimateButton()
                        print("Succeded creating a new account")
                    }
                }
            }
        }
    }
    
    //Segment for login / register changed.
    @IBAction func changeSegment(_ sender: Any) {
        if segment.selectedSegmentIndex == 0{
            firstNameStack.isHidden = true
            actionButton.setTitle("Login", for: .normal)
        }
        else{
            firstNameStack.isHidden = false
            actionButton.setTitle("Register", for: .normal)
        }
    }
    
    //Hide keyboard if screen was tapped.
    @IBAction func tappedOnScreen(_ sender: Any) {
        email.resignFirstResponder()
        password.resignFirstResponder()
        firstName.resignFirstResponder()
    }
    
    //Stopping the button animation
    func stopAnimateButton(){
        self.actionButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.2) {
            self.setCornerRadiusForButton()
        }
    }
    
    //Sets the corner radius of the button
    func setCornerRadiusForButton(){
        actionButton.cornerRadius = 5.0
    }
}
