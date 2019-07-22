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
    var events: [Event]{
        get{
            return userEvents + otherEvents
        }
    }
    var userEvents: [Event] = []
    var otherEvents: [Event] = []
    var eventRefs: [String] = []
    
    func createNewEvent(title: String, date: Date, hostRef: String, state: String, venue: String, openToAnyone: Bool, isCompetitive: Bool, headerPhotoRef: String?, attendingUserRefs: [String], game: String, address: String, completion: @escaping (Event) -> Void){
        guard let user = UserController.shared.currentUser else {return}
        //this function needs to create a new event, save a ref to it to the user who made it, and add it to firestore so other users can find it.
        let newEvent = Event(title: title, date: date, hostRef: hostRef, state: state, venue: venue, openToAnyone: openToAnyone, isCompetitive: isCompetitive, headerPhotoRef: headerPhotoRef, attendingUserRefs: attendingUserRefs, game: game, address: address)
        EventController.shared.userEvents.append(newEvent)
        let eventDict = EventController.shared.createDictionary(fromEvent: newEvent)
        FirebaseService.shared.addDocument(documentName: newEvent.uuid, collectionName: FirebaseReferenceManager.eventsCollection, data: eventDict) { (success) in
            print("tried to save the event to firebasee. Success: \(success)🥾🥾🥾")
            user.eventRefs.insert(newEvent.uuid, at: 0)
            completion(newEvent)
        }
    }
    
    func saveEventPhoto(image: UIImage, forEvent event: Event){
        guard let data = image.jpegData(compressionQuality: 0.7), let docName = event.headerPhotoRef else {return}
        FirebaseService.shared.addDocument(documentName: docName, collectionName: FirebaseReferenceManager.eventPicCollection, data: ["data" : data]) { (success) in
            print("tried to save the event's photo data to firestore. Success: \(success)🎩🎩🎩")
        }
    }
    
    func createDictionary(fromEvent event: Event) -> [String : Any]{
        let returnDict: [String : Any] = ["uuid" : event.uuid, "title" : event.title, "date" : event.date, "hostRef" : event.hostRef, "state" : event.state, "venue" : event.venue, "openToAnyone" : event.openToAnyone, "isCompetitive" : event.isCompetitive, "headerPhotoRef" : event.headerPhotoRef, "attendingUserRefs" : event.attendingUserRefs, "game" : event.game, "address" : event.address]
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
    
    func updateEvent(event: Event){
        let eventDict = EventController.shared.createDictionary(fromEvent: event)
        FirebaseService.shared.addDocument(documentName: event.uuid, collectionName: FirebaseReferenceManager.eventsCollection, data: eventDict) { (success) in
            print("tried to update the event in firebase. Success: \(success)🧣🧣🧣")
        }
    }
    
    func fetchEvents(completion: @escaping () -> Void){
        print("In the completion for event fetch🎒🎒🎒")
        let collectionRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.eventsCollection)
        collectionRef.getDocuments { (snapshot, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion()
                return
            }
            guard let snapshot = snapshot, let user = UserController.shared.currentUser else {completion(); return}
            for document in snapshot.documents{
                if let loadedEvent = Event(firestoreDocument: document.data()){
                    if user.eventRefs.contains(loadedEvent.uuid) && !EventController.shared.userEvents.contains(where: {$0.uuid == loadedEvent.uuid}){
                        EventController.shared.userEvents.append(loadedEvent)
                    } else if !EventController.shared.otherEvents.contains(where: {$0.uuid == loadedEvent.uuid}) {
                        EventController.shared.otherEvents.append(loadedEvent)
                    }
                }
            }
            print("loaded \(EventController.shared.events.count) events")
            completion()
        }
    }
}
