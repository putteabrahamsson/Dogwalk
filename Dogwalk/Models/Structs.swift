//
//  Structs.swift
//  Dogwalk
//
//  Created by Putte on 2020-03-02.
//  Copyright © 2020 Putte. All rights reserved.
//

import Foundation

//Struct for handeling the API call
struct ResponseData : Codable{
    let name: String
    let sys: CountryData
}

//Retrieving country code. 
struct CountryData: Codable{
    let country: String
}
