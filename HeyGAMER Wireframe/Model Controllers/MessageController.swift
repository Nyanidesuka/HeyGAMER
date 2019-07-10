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
}
