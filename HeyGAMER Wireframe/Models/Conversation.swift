//
//  Conversation.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation

class Conversation{
    var userRefs: [String]
    var messages: [Message]{
        didSet{
            print("fired the messages didset!⛳️⛳️⛳️")
            DispatchQueue.main.async {
                self.delegate?.updateMessages(forConversation: self)
            }
        }
    }
    var uuid: String
    var delegate: ConversationDelegate?{
        didSet{
            print("fired the delegate didset!⛳️⛳️⛳️")
        }
    }
    
    init(users: [String], messages: [Message] = [], uuid: String = UUID().uuidString){
        self.uuid = uuid
        self.messages = messages
        self.userRefs = users
    }
    
    convenience init?(firebaseDocument data: [String : Any]){
        guard let userRefs = data["userRefs"] as? [String],
            let messages = data["messages"] as? [[String : Any]],
            let uuid = data["uuid"] as? String else {return nil}
        //convert the messages to messages
        var convertedMessages: [Message] = []
        for dict in messages{
            guard let loadedMessage = Message(firestoreDocument: dict) else {return nil}
            convertedMessages.insert(loadedMessage, at: 0)
        }
        self.init(users: userRefs, messages: convertedMessages, uuid: uuid)
    }
}

protocol ConversationDelegate{
    func updateMessages(forConversation conversation: Conversation)
}
