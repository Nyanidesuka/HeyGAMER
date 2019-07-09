//
//  Message.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation

class Message{
    
    var username: String
    var text: String
    var timestamp: Date
    var uuid: String
    
    init(username: String, text: String, timestamp: Date = Date(), uuid: String = UUID().uuidString){
        self.username = username
        self.uuid = uuid
        self.text = text
        self.timestamp = timestamp
    }
}
