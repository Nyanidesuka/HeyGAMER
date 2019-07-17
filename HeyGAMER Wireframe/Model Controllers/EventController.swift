//
//  EventController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import Firebase

class EventController{
    
    static let shared = EventController()
    var events: [Event] = []
    var eventRefs: [String] = []
    
    func createDictionary(fromEvent event: Event) -> [String : Any]{
        let returnDict: [String : Any] = ["uuid" : event.uuid, "title" : event.title, "date" : event.date, "hostRef" : event.hostRef, "state" : event.state, "venue" : event.venue, "openToAnyone" : event.openToAnyone, "isCompetitive" : event.isCompetitive, "headerPhotoRef" : event.headerPhotoRef, "attendingUserRefs" : event.attendingUserRefs]
        return returnDict
    }
    
    func fetchUsers(forEvent event: Event, index: Int = 0, completion: @escaping () -> Void){
        let userDocName = event.attendingUserRefs[index]
        FirebaseService.shared.fetchDocument(documentName: userDocName, collectionName: FirebaseReferenceManager.userCollection) { (document) in
            guard let document = document, let loadedUser = User(firestoreDoc: document) else {print("couldn't load a user from this reference. 💈💈💈💈"); completion(); return}
            event.attendingUsers.append(loadedUser)
            if event.attendingUsers.count < event.attendingUserRefs.count{
                print("so far we have \(event.attendingUsers) users from \(event.attendingUserRefs) references. Going for another lap. 🕹🕹🕹")
                EventController.shared.fetchUsers(forEvent: event, index: index + 1, completion: completion)
            } else {
                print("completing with \(event.attendingUsers) users from \(event.attendingUserRefs) refs! 🕹🕹🕹")
                completion()
            }
        }
    }
    
    func fetchImage(forEvent event: Event, completion: @escaping () -> Void){
        guard let docName = event.headerPhotoRef, !docName.isEmpty else {print("event has no photo associated with it💈💈💈💈💈💈");return}
        FirebaseService.shared.fetchDocument(documentName: docName, collectionName: FirebaseReferenceManager.eventPicCollection) { (document) in
            guard let document = document, let photoData = document["data"] as? Data else {completion(); return}
            let loadedImage = UIImage(data: photoData)
            event.headerPhoto = loadedImage
            completion()
        }
    }
}
