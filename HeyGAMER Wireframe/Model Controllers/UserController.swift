//
//  UserController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import FirebaseAuth

class UserController{
    
    static let shared = UserController()
    var currentUser: User?
    var loadedUsers: [User] = []
    
    func createDictionary(fromUser user: User) -> [String : Any]{
        let returnDict: [String : Any] = ["username" : user.username, "eventRefs" : user.eventRefs, "bio" : user.bio, "nowPlaying" : user.nowPlaying, "lookingFor" : user.lookingFor, "favoriteGames" : user.favoriteGames, "favoriteGenres" : user.favoriteGenres, "pfpDocName" : user.pfpDocName, "authUserRef" : user.authUserRef, "blockedUsers" : user.blockedUserRefs, "cityState" : user.cityState]
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
    
    func fetchUsers(completion: @escaping () -> Void){
        FirebaseService.shared.fetchCollection(collectionName: "Users") { (snapshot) in
            guard let snapshot = snapshot else {print("couldn't unwrap the snap"); return}
            let documents = snapshot.documents
            for document in documents{
                guard let loadedUser = User(firestoreDoc: document.data()), let userID = Auth.auth().currentUser?.uid, let currentUser = UserController.shared.currentUser, !currentUser.blockedUserRefs.contains(loadedUser.authUserRef) else {print("couldn't make a user from the document OR the user is blocked."); return}
                print("Loaded user: \(loadedUser.username) 🔋🔋")
                if loadedUser.authUserRef != userID && !self.loadedUsers.contains(where: {$0.authUserRef == loadedUser.authUserRef}){
                    print("Adding them to the SoT")
                    self.loadedUsers.append(loadedUser)
                }
            }
            completion()
        }
    }
}
