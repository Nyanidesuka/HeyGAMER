//
//  Event.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Event{
    var uuid: String
    var title: String
    var date: Date
    var host: User?
    var hostRef: String
    var state: String
    var venue: String
    var openToAnyone: Bool
    var isCompetitive: Bool
    var headerPhoto: UIImage?
    var headerPhotoRef: String?
    var attendingUsers: [User] = []
    var attendingUserRefs: [String]
    
    init(uuid: String = UUID().uuidString, title: String, date: Date, hostRef: String, state: String, venue: String, openToAnyone: Bool, isCompetitive: Bool, headerPhotoRef: String? = nil, attendingUserRefs: [String]){
        self.uuid = uuid
        self.title = title
        self.date = date
        self.hostRef = hostRef
        self.state = state
        self.venue = venue
        self.openToAnyone = openToAnyone
        self.isCompetitive = isCompetitive
        self.headerPhotoRef = headerPhotoRef
        self.attendingUserRefs = attendingUserRefs
    }
    
    //now we need an init from a firestore doc
    convenience init?(firestoreDocument data: [String : Any]){
        guard let uuid = data["uuid"] as? String,
        let title = data["title"] as? String,
        let date = data["date"] as? Timestamp,
        let hostRef = data["hostRef"] as? String,
        let state = data["state"] as? String,
        let venue = data["venue"] as? String,
        let openToAnyone = data["openToAnyone"] as? Bool,
        let isCompetitive = data["isCompetitive"] as? Bool,
        let headerPhotoRef = data["headerPhotoRef"] as? String,
            let attendingUserRefs = data["attendingUserRefs"] as? [String] else {print("couldn't get all of the information we needed from the document to make an event.🖲🖲🖲"); return nil}
        self.init(uuid: uuid, title: title, date: date.dateValue(), hostRef: hostRef, state: state, venue: venue, openToAnyone: openToAnyone, isCompetitive: isCompetitive, headerPhotoRef: headerPhotoRef, attendingUserRefs: attendingUserRefs)
    }
}
