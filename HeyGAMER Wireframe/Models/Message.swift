//
//  Message.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import Firebase

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
    
    convenience init?(firestoreDocument data: [String : Any]){
        guard let username = data["username"] as? String,
        let timestamp = data["timestamp"] as? Timestamp,
        let text = data["text"] as? String,
            let uuid = data["uuid"] as? String else {print("couldnt unwrap all of the info from the dictionary."); return nil}
        self.init(username: username, text: text, timestamp: timestamp.dateValue(), uuid: uuid)
    }
}
