//
//  FirebaseService.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import Firebase

class FirebaseService{
    static let shared = FirebaseService()
    func addDocument(documentName document: String, collectionName collection: String, data: [String : Any], completion: @escaping (Bool) -> Void){
        FirebaseReferenceManager.root.collection(collection).document(document).setData(data) { (error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func fetchCollection(completion: @escaping (QuerySnapshot?) -> Void){
        FirebaseReferenceManager.root.collection("Messages").getDocuments { (snapshot, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion(nil)
                return
            }
            print("got documents☑️☑️☑️☑️☑️☑️☑️☑️☑️")
            completion(snapshot)
            return
        }
    }
    
    func fetchDocument(documentName: String, collectionName: String, completion: @escaping ([String : Any]?) -> Void){
        let docRef = FirebaseReferenceManager.root.collection(collectionName).document(documentName)
        docRef.getDocument { (document, error) in
            if let error = error{
                print("there was an error in \(#function) - \(error)")
                completion(nil)
                return
            }
            completion(document?.data())
        }
    }
}
