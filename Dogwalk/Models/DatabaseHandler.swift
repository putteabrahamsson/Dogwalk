//
//  DatabaseHandler.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-26.
//  Copyright © 2020 Putte. All rights reserved.
//

import Foundation
import Firebase

class DatabaseHandler{
    
    //UserDefaults
    let defaults = UserDefaults.standard
    
    //Database references
    var dbRef:DatabaseReference!
    let db = Firestore.firestore()
    
    //Authentication
    let authentication = Auth.auth().currentUser?.uid
    
    //Initializer
    init() {
        dbRef = Database.database().reference()
    }
    
    //MARK: - Create account
    func createAccount(email: String, firstName: String, completed: @escaping () -> ()){
        let uuid = UUID().uuidString
        
        db.collection("users").addDocument(data:[
            "email" : email,
            "groupId": uuid,
            "newInviteId": "",
            "newGroupName": "",
            "newInvite": 0,
            "firstName": firstName,
            "inGroup": false
        ]) { (err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                DispatchQueue.main.async {
                    completed()
                }
            }
        }
    }
    
    //MARK: - Retrieve user data
    func retrieveData(email: String, completed: @escaping () -> ()){
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                for element in snapshot!.documents{
                    let data = element.data()
                    
                    let email = data["email"] as! String
                    let groupId = data["groupId"] as! String
                    let firstName = data["firstName"] as! String
                    let inGroup = data["inGroup"] as! Bool
                    
                    self.defaults.set(email, forKey: "email")
                    self.defaults.set(groupId, forKey: "groupId")
                    self.defaults.set(firstName, forKey: "firstname")
                    self.defaults.set(inGroup, forKey: "inGroup")
                    self.defaults.synchronize()
                    
                    DispatchQueue.main.async {
                        completed()
                    }
                }
            }
        }
    }
    
    //MARK: - Group properties
    // Create a new group
    func createGroup(textField: String, uuid: String){
        db.collection("groups").document(uuid).collection("groupData").addDocument(data: [
            "groupId":uuid,
            "groupName": textField
        ]) { (err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                self.defaults.set(uuid, forKey: "groupId")
                self.defaults.set(textField, forKey: "groupName")
                self.defaults.synchronize()
                self.addUserToGroup(uuid: uuid)
            }
        }
    }
    
    //MARK: - Add the user to group.
    func addUserToGroup(uuid: String){
        let email = defaults.string(forKey: "email")
        let firstname = defaults.string(forKey: "firstname")
        db.collection("groups").document(uuid).collection("groupUsers").addDocument(data: ["email" : email!, "auth": authentication!, "firstname": firstname!]) { (err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                self.setInGroup()
            }
        }
    }
    
    //MARK: - Set user to ingroup
    func setInGroup(){
        let email = defaults.string(forKey: "email")
        db.collection("users").whereField("email", isEqualTo: email!).getDocuments { (snapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                for document in snapshot!.documents{
                    document.reference.updateData(["inGroup":true]) { (err) in
                        if let err = err{
                            print(err.localizedDescription)
                        }
                        else{
                            self.defaults.set(true, forKey: "inGroup")
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Add dog to group
    func addDogToGroup(dogName: String, url: String, completed: @escaping () -> ()){
        let groupId = defaults.string(forKey: "groupId")
        
        db.collection("groups").document(groupId!).collection("groupDogs").addDocument(data:[
            "dogName" : dogName,
            "imageUrl": url
        ]) { (err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                DispatchQueue.main.async {
                    completed()
                }
            }
        }
    }
    
    //MARK: - Accept / deny group
    func acceptGroupInvite(accept: Bool!, completed: @escaping () -> ()){
        let email = defaults.string(forKey: "email")
        
        db.collection("users").whereField("email", isEqualTo: email!).getDocuments { (snapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                for snap in snapshot!.documents{
                    let data = snap.data()
                    
                    let groupId = data["groupId"] as! String
                    let newInviteId = data["newInviteId"] as! String
                    
                    //User accepted the invitation
                    if accept == true{
                        snap.reference.updateData([
                            "groupId" : newInviteId,
                            "newInviteId": "",
                            "newGroupName": "",
                            "newInvite": 0
                        ]) { (err) in
                            if let err = err{
                                print(err.localizedDescription)
                            }
                            else{
                                self.defaults.set(newInviteId, forKey: "groupId")
                                self.addUserToGroup(uuid: newInviteId)
                                completed()
                            }
                        }
                    }
                    //User denied the invitation
                    else{
                        snap.reference.updateData([
                            "groupId" : groupId,
                            "newInviteId": "",
                            "newGroupName": "",
                            "newInvite": 0
                        ]) { (err) in
                            if let err = err{
                                print(err.localizedDescription)
                            }
                            else{
                                completed()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Get groupname
    func getGroupName(completed: @escaping (String) -> ()){
        let groupId = defaults.string(forKey: "groupId")
        db.collection("groups").document(groupId!).collection("groupData").getDocuments { (snapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                for document in snapshot!.documents{
                    let data = document.data()
                    let groupName = data["groupName"] as! String
                    
                    DispatchQueue.main.async {
                        completed(groupName)
                    }
                }
            }
        }
    }
    
    //Invite a user to the group
    func inviteUserToGroup(email: String!, groupName: String!){
        let newInviteId = defaults.string(forKey: "groupId")
        
        db.collection("users").whereField("email", isEqualTo: email!).getDocuments { (snapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                let data = snapshot!.documents.first
                data?.reference.updateData([
                    "newInviteId": newInviteId!,
                    "newGroupName": groupName!,
                    "newInvite": 1
                    ], completion: { (err) in
                        if let err = err{
                            print(err.localizedDescription)
                        }
                })
            }
        }
    }
    
    //MARK: - Retreive dogs
    func getDogs(completed: @escaping ([DogData]) -> ()){
        let groupId = defaults.string(forKey: "groupId")
        var tempArray:[DogData] = []
        db.collection("groups").document(groupId!).collection("groupDogs").getDocuments { (snapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                for document in snapshot!.documents{
                    let data = document.data()
                    
                    let dogName = data["dogName"] as! String
                    let dogImageUrl = data["imageUrl"] as! String
                    let documentId = document.documentID
                    
                    let txt = DogData.init(dogName: dogName, dogImageUrl: dogImageUrl, documentId: documentId)
                    
                    tempArray.append(txt)
                    
                    DispatchQueue.main.async {
                        completed(tempArray)
                    }
                }
            }
        }
        
    }
    
    //MARK: - Remove dog
    func removeDog(dogPath: String, completed: @escaping () -> ()){
        let groupId = defaults.string(forKey: "groupId")
        db.collection("groups").document(groupId!).collection("groupDogs").document(dogPath).delete { (err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                DispatchQueue.main.async {
                    completed()
                }
            }
        }
    }
    
    //MARK: - Get notifications
    func getNotification(completed: @escaping (Int) -> ()){
        let email = defaults.string(forKey: "email")
    
        db.collection("users").whereField("email", isEqualTo: email!).getDocuments { (snapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                for documents in snapshot!.documents{
                    let data = documents.data()
                    let newNotification = data["newInvite"] as! Int
                    
                    DispatchQueue.main.async {
                        completed(newNotification)
                    }
                }
            }
        }
    }

    //Display invite in notification
    func getNotificationData(completed: @escaping ([NotificationHolder]) -> ()){
        
        let email = defaults.string(forKey: "email")
        
        var tempArray:[NotificationHolder] = []
        db.collection("users").whereField("email", isEqualTo: email!).getDocuments { (snapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                for snap in snapshot!.documents{
                    let data = snap.data()
                    let groupName = data["newGroupName"] as! String
                    let groupId = data["newInviteId"] as! String
                    
                    let txt = NotificationHolder.init(groupName: groupName, groupId: groupId)
                    
                    tempArray.append(txt)
                    
                    DispatchQueue.main.async {
                        completed(tempArray)
                    }
                }
            }
        }
    }
    
    //MARK: - Get members
    func getMembers(completed: @escaping ([MemberData]) -> ()){
        let groupId = defaults.string(forKey: "groupId")
        
        var tempArray:[MemberData] = []
        db.collection("groups").document(groupId!).collection("groupUsers").getDocuments { (snapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                for document in snapshot!.documents{
                    let data = document.data()
                    let firstName = data["firstname"] as! String
                    let email = data["email"] as! String
                    
                    let txt = MemberData.init(firstName: firstName, email: email)
                    tempArray.append(txt)
                }
                
                DispatchQueue.main.async {
                    completed(tempArray)
                }
            }
        }
    }
    
    //MARK: - Save a new walk
    func saveNewWalk(dog: String, person: String, action: String, date: String, dogImage: String, longitude: Double, latitude: Double, completed: @escaping () -> ()){

        let groupId = defaults.string(forKey: "groupId")
        dbRef.child("walks").child(groupId!).childByAutoId().setValue([
            "dog": dog,
            "person": person,
            "action": action,
            "dateTime": date,
            "dogImage": dogImage,
            "longitude": longitude,
            "latitude": latitude
        ]) { (err, ref) in
            if let err = err{
                print(err.localizedDescription)
            }
            else{
                completed()
            }
        }
    }
    
    //MARK: - Get all walks
    func getWalks(completed: @escaping ([HistoryData], [HistoryData]) -> ()){
        let groupId = defaults.string(forKey: "groupId")
        
        //Arrays
        var tempArray:[HistoryData] = []
        var todayArray:[HistoryData] = []
        
        //Get current date
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let todaysDate = formatter.string(from: date)
        
        self.dbRef.child("walks").child(groupId!).queryOrdered(byChild: "dateTime").observe(.value) { (snapshot) in
            tempArray = []
            todayArray = []
            for child in snapshot.children{
                let childSnap = child as! DataSnapshot
                let data = childSnap.value as! [String:Any]
                
                //Set data to variables
                let dog = data["dog"] as! String
                let person = data["person"] as! String
                let action = data["action"] as! String
                let dateTime = data["dateTime"] as! String
                let dogImage = data["dogImage"] as! String
                let longitude = data["longitude"] as! Double
                let latitude = data["latitude"] as! Double
                
                //Get date of the walk.
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "sv")
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                let dateAndTime = dateFormatter.date(from:dateTime)
                
                //Sets the date format to year, month and day.
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let date = dateFormatter.string(from: dateAndTime!)
                
                //Insert into HistoryData
                let txt = HistoryData.init(dog: dog, person: person, action: action, dateTime: dateTime, dogImage: dogImage, longitude: longitude, latitude: latitude)
                
                //Append data depending on date.
                if todaysDate == date{
                    todayArray.append(txt)
                }
                else{
                    tempArray.append(txt)
                }
                
                DispatchQueue.main.async {
                    completed(tempArray, todayArray)
                }
            }
        }
    }
}
