//
//  UserController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation

class UserController{
    
    static let shared = UserController()
    var currentUser: User?
    
    func createDictionary(fromUser user: User) -> [String : Any]{
        let returnDict: [String : Any] = ["username" : user.username, "eventRefs" : user.eventRefs, "bio" : user.bio, "nowPlaying" : user.nowPlaying, "lookingFor" : user.lookingFor, "favoriteGames" : user.favoriteGames, "favoriteGenres" : user.favoriteGenres, "pfpDocName" : user.pfpDocName, "authUserRef" : user.authUserRef]
        return returnDict
    }
    
    func updateUserDocument(){
        guard let user = UserController.shared.currentUser else {return}
        let userDict = UserController.shared.createDictionary(fromUser: user)
        FirebaseService.shared.addDocument(documentName: user.authUserRef, collectionName: "Users", data: userDict) { (success) in
            print("tried to update the user. Success: \(success)")
        }
    }
    
    func updateConversationRefs(withNewRef ref: String){
        guard let user = UserController.shared.currentUser else {return}
        let collectionRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.userCollection).document(user.authUserRef).collection("conversationRefs")
        //turn each of the user's conversation references into a dictionary and then add it to the collection!
        let refDict: [String : Any] = ["ref" : ref]
        collectionRef.addDocument(data: refDict)
    }
}
