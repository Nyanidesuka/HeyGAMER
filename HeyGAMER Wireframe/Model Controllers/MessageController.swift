//
//  MessageController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation

class MessageController{
    
    static let shared = MessageController()
    
    func createMessage(withText text: String) -> Message?{
        guard let user = UserController.shared.currentUser else {return nil}
        let newMessage = Message(username: user.username, text: text)
        return newMessage
    }
    
    func createDictionary(fromMessage message: Message) -> [String : Any]{
        return ["username" : message.username, "text" : message.text, "timestamp" : message.timestamp, "uuid" : message.uuid]
    }
    func getMessages(withConversationRef ref: String, completion: @escaping () -> Void){
        print("the \(#function) is firing✲✲✲✲✲✲✲")
        //find the actual conversation object
        guard let targetConversation = ConversationController.shared.conversations.first(where: {$0.uuid == ref}) else {print("couldnt find the conversation in the SoT🐝🐝🐝");completion(); return}
        //pull the messages, then find which ones are new
        FirebaseService.shared.fetchDocument(documentName: ref, collectionName: FirebaseReferenceManager.conversationCollection) { (document) in
            guard let document = document, let messages = document["messages"] as? [[String : Any]] else {print("couldnt unwrap the document 🐝🐝🐝"); return}
            for dict in messages{
                guard let loadedMessage = Message(firestoreDocument: dict) else {print("couldn't make a message from the document🐝🐝🐝"); return}
                if !targetConversation.messages.contains(where: {$0.uuid == loadedMessage.uuid}){
                    print("inserting a new message into the conversation! 💰💰💰")
                    targetConversation.messages.insert(loadedMessage, at: 0)
                }
                //we might need to sort the collection by date again.
            }
            completion()
        }
    }
}
