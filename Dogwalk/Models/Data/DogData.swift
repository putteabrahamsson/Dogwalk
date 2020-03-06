//
//  DogData.swift
//  Dogwalk
//
//  Created by Putte on 2020-02-27.
//  Copyright © 2020 Putte. All rights reserved.
//

import Foundation

class DogData{
    //Strings
    var dogName: String
    var dogImageUrl: String
    var documentId: String
    
    //Initializer
    init(dogName: String, dogImageUrl: String, documentId: String) {
        self.dogName = dogName
        self.dogImageUrl = dogImageUrl
        self.documentId = documentId
    }
}

