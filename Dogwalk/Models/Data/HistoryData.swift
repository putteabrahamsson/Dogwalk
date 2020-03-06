//
//  HistoryData.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-27.
//  Copyright © 2020 Putte. All rights reserved.
//

import Foundation

class HistoryData{
    //Variables
    var dog: String
    var person: String
    var action: String
    var dateTime: String
    var dogImage: String
    var longitude: Double
    var latitude: Double
    
    //Initializer
    init(dog: String, person: String, action: String, dateTime: String, dogImage: String, longitude: Double, latitude: Double) {
        self.dog = dog
        self.person = person
        self.action = action
        self.dateTime = dateTime
        self.dogImage = dogImage
        self.longitude = longitude
        self.latitude = latitude
    }
}
