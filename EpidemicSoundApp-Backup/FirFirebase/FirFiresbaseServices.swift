//
//  FirFiresbaseServices.swift
//  EpedimicSound
//
//  Created by Danilo Rivera on 11/29/19.
//  Copyright © 2019 Danilo Rivera. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirFirestoreServices {
    
    private init() {}
    
    static let shared = FirFirestoreServices()
    
    func config() {
        FirebaseApp.configure()
    }
    
    
    private func reference(to collectionReference: FirCollectionReference) -> CollectionReference {
        return Firestore.firestore().collection(collectionReference.rawValue)
    }
    
    func readTracks<T: Decodable>(from collectionReference: FirCollectionReference, returning objectType: T.Type, completion: @escaping([T]) -> Void){
        
        reference(to: collectionReference).limit(to: 10).order(by: "order", descending: true).addSnapshotListener { (snapshot, _) in
            guard let snapshot = snapshot else { return }
            
            do {
                var objects = [T]()
                for document in snapshot.documents {
                    let object = try document.decode(as: objectType.self)
                    objects.append(object)
                }
                
                completion(objects)

            } catch {
                print(error)
            }
            
        }
    }
    
    
        
}
    
    

