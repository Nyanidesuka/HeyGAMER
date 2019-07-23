//
//  ConversationController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import UIKit
class ConversationController{
    //SoT
    static let shared = ConversationController()
    var conversations: [Conversation] = []
    
    
    func addMessage(toConversation conversation: Conversation, message: Message){
        conversation.messages.insert(message, at: 0)
        let convoDict = ConversationController.shared.createDictionary(fromConversation: conversation)
        FirebaseService.shared.addDocument(documentName: conversation.uuid, collectionName: FirebaseReferenceManager.conversationCollection, data: convoDict) { (success) in
            print("tried to update the conversation with a new message. Success: \(success)")
        }
    }
    
    func createConversation(initialMessage: Message, users: [String], sender: ConversationDelegate, completion: @escaping (Conversation) -> Void){
        let newConversation = Conversation(users: users, messages: [initialMessage], uuid: UUID().uuidString)
        ConversationController.shared.conversations.insert(newConversation, at: 0)
        let convoDict = ConversationController.shared.createDictionary(fromConversation: newConversation)
        FirebaseService.shared.addDocument(documentName: newConversation.uuid, collectionName: FirebaseReferenceManager.conversationCollection, data: convoDict) { (success) in
            print("tried to create a new conversation. Success: \(success)")
            completion(newConversation)
        }
        newConversation.delegate = sender
        //add an observer to the new conversation
        let docRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.conversationCollection).document(newConversation.uuid)
        let ref = newConversation.uuid
        docRef.addSnapshotListener({ (snapshot, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                return
            }
            MessageController.shared.getMessages(withConversationRef: newConversation.uuid, completion: {
                print("completion of the observer for a NEW conversation 🥎🥎🥎")
                newConversation.delegate?.updateMessages(forConversation: newConversation)
            })
        })
    }
    
    func createDictionary(fromConversation conversation: Conversation) -> [String : Any]{
        var messageDictArray: [[String : Any]] = []
        for message in conversation.messages{
            let messageDict = MessageController.shared.createDictionary(fromMessage: message)
            messageDictArray.insert(messageDict, at: 0)
        }
        
        return ["userRefs" : conversation.userRefs, "messages" : messageDictArray, "uuid" : conversation.uuid]
    }
    //i actually hate this but i cant find a way to get all these documents in one round trip
    func fetchUserConversations(index: Int = 0, completion: @escaping () -> Void){
        guard let user = UserController.shared.currentUser, !user.conversationRefs.isEmpty else {print("there is no current user OR they have no conversations"); completion(); return}
        print("user has \(user.conversationRefs.count) refs and we're about to try and fetch index \(index)")
        FirebaseService.shared.fetchDocument(documentName: user.conversationRefs[index], collectionName: FirebaseReferenceManager.conversationCollection) { (document) in
            guard let document = document, let loadedConversation = Conversation(firebaseDocument: document) else {return}
            if !ConversationController.shared.conversations.contains(where: {$0.uuid == loadedConversation.uuid}){
                ConversationController.shared.conversations.insert(loadedConversation, at: 0)
            }
            if ConversationController.shared.conversations.count < user.conversationRefs.count{
                self.fetchUserConversations(index: index + 1, completion: completion)
            } else {
                print("completing with \(ConversationController.shared.conversations.count) conversations, \(user.conversationRefs)🏈")
                print("removing blocked user conversations...")
                for conversation in ConversationController.shared.conversations{
                    guard let otherUserRef = conversation.userRefs.first(where: {$0 != user.authUserRef}),
                        let targetIndex = ConversationController.shared.conversations.firstIndex(where: {$0.uuid == conversation.uuid}) else {completion(); return}
                    if user.blockedUserRefs.contains(otherUserRef){
                        print("removing a conversation because it involves a blocked user")
                        ConversationController.shared.conversations.remove(at: targetIndex)
                    }
                }
                self.checkIfBlocked(completion: {
                    completion()
                })
            }
        }
    }
    
    func checkIfBlocked(index: Int = 0, completion: @escaping () -> Void){
        guard !ConversationController.shared.conversations.isEmpty else {completion(); return}
        guard let currentUser = UserController.shared.currentUser, let otherUserRef = ConversationController.shared.conversations[index].userRefs.first(where: {$0 != currentUser.authUserRef}) else {print("failed the first guard");return}
        FirebaseService.shared.fetchDocument(documentName: otherUserRef, collectionName: FirebaseReferenceManager.userCollection) { (document) in
            guard let document = document, let blockedUsers = document["blockedUsers"] as? [String] else {print("couldn't get the blocked users"); completion(); return}
            if blockedUsers.contains(currentUser.authUserRef){
                print("removing conversations")
                ConversationController.shared.conversations.remove(at: index)
                if index < ConversationController.shared.conversations.count - 1{
                    self.checkIfBlocked(index: index, completion: completion)
                } else {
                    completion()
                }
            } else {
                print("no need to remove this conversation")
                if index < ConversationController.shared.conversations.count - 1{
                    self.checkIfBlocked(index: index + 1, completion: completion)
                } else {
                    completion()
                }
            }
        }
    }
    
    func fetchConversationRefs(completion: @escaping () -> Void){
        guard let user = UserController.shared.currentUser else {completion(); return}
        let collectionRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.userCollection).document(user.authUserRef).collection("conversationRefs")
        collectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion()
                return
            }
            guard let snapshot = snapshot else {print("couldnt unwrap the snap"); return}
            for document in snapshot.documents{
                guard let ref = document.data()["ref"] as? String else {return}
                UserController.shared.currentUser?.conversationRefs.insert(ref, at: 0)
            }
            completion()
        }
    }
    
    func updateLocalConversation(conversation: Conversation, completion: @escaping (Bool) -> Void){
        //what this function needs to do is pull a conversation's messages from firestore and update its messages locally
        FirebaseService.shared.fetchDocument(documentName: conversation.uuid, collectionName: FirebaseReferenceManager.conversationCollection) { (document) in
            guard let document = document, let messages = document["messages"] as? [[String : Any]] else {completion(false); return}
            for message in messages{
                guard let loadedMessage = Message(firestoreDocument: message) else {return}
                if !conversation.messages.contains(where: {$0.uuid == loadedMessage.uuid}){
                    conversation.messages.insert(loadedMessage, at: 0)
                }
            }
            completion(true)
        }
    }
    
    func filterForBlockedUsers(index: Int = 0, completion: @escaping () -> Void){
        guard let user = UserController.shared.currentUser, let otherUserRef = ConversationController.shared.conversations[index].userRefs.first(where: {$0 != user.authUserRef}) else {return}
        //first check if we have the user already
        if let otherUser = UserController.shared.loadedUsers.first(where: {$0.authUserRef == otherUserRef}){
            if otherUser.blockedUserRefs.contains(user.authUserRef){
                ConversationController.shared.conversations.remove(at: index)
            }
        }
        FirebaseService.shared.fetchDocument(documentName: otherUserRef, collectionName: FirebaseReferenceManager.userCollection) { (document) in
            
        }
    }
}
