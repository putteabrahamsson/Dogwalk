//
//  Extensions.swift
//  Dogwalk
//
//  Created by Putte on 2020-03-02.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import Firebase

//Image caching
let imageCache = NSCache<AnyObject, AnyObject>()

//MARK: - Display alert
//Extension for displaying an alert view.
extension UIViewController{
    
    //Displays a basic alert with two buttons
    func displayMessageAlertView(title: String, message: String, actionTitle: String){
        
        //Create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //Add a button to the alert.
        alert.addAction(UIAlertAction.init(title: actionTitle, style: .default, handler: nil))
        
        //Present the alert
        self.present(alert, animated: true)
    }
}

//MARK: - Image downloading
//Extension for downloading images from a website.
extension UIImageView {
    func downloadImages(from urlString: NSString){
        
        //Check for cached images and return out if found
        if let cachedImage = imageCache.object(forKey: urlString) as? UIImage{
            self.image = cachedImage
            return
        }
        
        //Retrieve the images from Firebase Storage
        let url = URL(string: urlString as String)
        
        //Create an URL session
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            
            //Continue on background thread
            DispatchQueue.main.async {
                //Check if image exists
                if let downloadedImage = UIImage(data: data!){
                    
                    //Add image to cache
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    
                    //Set the image to downloaded image.
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}
