//
//  Snapshot Extensions.swift
//  Fire Demo App
//
//  Created by Danilo Rivera on 11/20/19.
//  Copyright © 2019 Danilo Rivera. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension DocumentSnapshot {
    
    func decode<T: Decodable>(as objectType: T.Type, includingID: Bool = true) throws -> T {
        
        var documentJson = data()
        
        if includingID {
            documentJson!["id"] = documentID
        }
        let documentData = try JSONSerialization.data(withJSONObject: documentJson!, options: [])
        let decodedObject = try JSONDecoder().decode(objectType, from: documentData)
        return decodedObject
        
    }
}


