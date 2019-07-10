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
    var messages: [Message]
    var uuid: String
    
    init(users: [String], messages: [Message] = [], uuid: String = UUID().uuidString){
        self.uuid = uuid
        self.messages = messages
        self.userRefs = users
    }
}
