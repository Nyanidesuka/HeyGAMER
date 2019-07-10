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
    
    func fetchCollection(collectionName: String, completion: @escaping (QuerySnapshot?) -> Void){
        FirebaseReferenceManager.root.collection(collectionName).getDocuments { (snapshot, error) in
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
    
    func sendConvoRef(toUser user: User, ref: String){
        let collectionRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.userCollection).document(user.authUserRef).collection("conversationRefs")
        collectionRef.addDocument(data: ["ref" : ref])
    }
    
    func fetchConversationRefs(completion: @escaping () -> Void){
        guard let user = UserController.shared.currentUser else {return}
        let collectionRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.userCollection).document(user.authUserRef).collection("conversationRefs")
        collectionRef.getDocuments { (snapshot, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion()
                return
            }
            guard let snapshot = snapshot else {print("Couldnt unwrap the snap"); return}
            for document in snapshot.documents{
                guard let ref = document.data()["ref"] as? String else {return}
                user.conversationRefs.insert(ref, at: 0)
            }
            completion()
        }
    }
}
