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
        let returnDict: [String : Any] = ["username" : user.username, "eventRefs" : user.eventRefs, "bio" : user.bio, "nowPlaying" : user.nowPlaying, "lookingFor" : user.lookingFor, "favoriteGames" : user.favoriteGames, "favoriteGenres" : user.favoriteGenres, "pfpDocName" : user.pfpDocName, "authUserRef" : user.authUserRef, "blockedUsers" : user.blockedUserRefs, "cityState" : user.cityState, "blockedEventRefs" : user.blockedEventRefs]
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
        var fetchedUsers: [User] = []
        FirebaseService.shared.fetchCollection(collectionName: "Users") { (snapshot) in
            guard let snapshot = snapshot else {print("couldn't unwrap the snap"); return}
            let documents = snapshot.documents
            for document in documents{
                if let loadedUser = User(firestoreDoc: document.data()), let userID = Auth.auth().currentUser?.uid, let currentUser = UserController.shared.currentUser, !currentUser.blockedUserRefs.contains(loadedUser.authUserRef){
                    print("Loaded user: \(loadedUser.username) 🔋🔋")
                    if loadedUser.authUserRef != userID && !fetchedUsers.contains(where: {$0.authUserRef == loadedUser.authUserRef}) && !loadedUser.blockedUserRefs.contains(userID){
                        print("Adding them to the SoT")
                        fetchedUsers.append(loadedUser)
                    }
                    //if we find a blocked user but theyre already loaded, remove them
                    if loadedUser.blockedUserRefs.contains(userID) || currentUser.blockedUserRefs.contains(loadedUser.authUserRef){
                        if fetchedUsers.contains(where: {$0.authUserRef == loadedUser.authUserRef}){
                            guard let targetIndex = fetchedUsers.firstIndex(where: {$0.authUserRef == loadedUser.authUserRef}) else {return}
                            fetchedUsers.remove(at: targetIndex)
                        }
                    }
                }
            }
            UserController.shared.loadedUsers = fetchedUsers
            completion()
        }
    }
}
