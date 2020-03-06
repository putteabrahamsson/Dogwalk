//
//  ApiHandler.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-28.
//  Copyright © 2020 Putte. All rights reserved.
//

import Foundation

class ApiHandler{
    
    //Create an array for holding our locations
    var location:[ResponseData] = []
    
    //Get the location
    func getLocation(url: String, completed: @escaping ([ResponseData]) -> ()){
        
        guard let url = URL(string: url) else{
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err{
                print(err.localizedDescription)
            }
            guard let data = data else{
                return
            }
            
            do{
                //Append the response to the array
                self.location = [try JSONDecoder().decode(ResponseData.self, from: data)]
                
                DispatchQueue.main.async {
                    completed(self.location)
                }
            }
            catch let jsonErr{
                print(jsonErr.localizedDescription)
            }
        }.resume()
    }
}

