//
//  Conversation.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation

class Conversation{
    var users: [User]
    var messages: [Message]
    var uuid: String
    
    init(users: [User], messages: [Message] = [], uuid: String = UUID().uuidString){
        self.uuid = uuid
        self.messages = messages
        self.users = users
    }
}
