//
//  User.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import CoreLocation

class User{
    
    var username: String
    //references to conversations this user is a part of
    var conversationRefs: [String]
    //references to events the user interacted with
    var eventRefs: [String]
    //Profile info
    var bio: String
    var nowPlaying: String
    var lookingFor: [String]
    var favoriteGames: [String]
    var favoriteGenres: [String]
    var location: CLLocation?
    var profilePicture: UIImage?
    var pfpDocName: String?
    //reference to the firebase auth doc for this user
    var authUserRef: String
    var blockedUserRefs: [String]
    var blockedEventRefs: [String]
    var cityState: String
    
    init(username: String, authUserRef: String, eventRefs: [String] = [], conversationRefs: [String] = [], bio: String = "", nowPlaying: String = "", lookingFor: [String] = [], favoriteGames: [String] = [], favoriteGenres: [String] = [], location: CLLocation? = nil, profilePicture: UIImage? = nil, pfpDocName: String? = nil, blockedUserRefs: [String] = [], cityState: String = "", blockedEventRefs: [String] = []){
        self.username = username
        self.authUserRef = authUserRef
        self.bio = bio
        self.lookingFor = lookingFor
        self.conversationRefs = conversationRefs
        self.eventRefs = eventRefs
        self.nowPlaying = nowPlaying
        self.favoriteGames = favoriteGames
        self.favoriteGenres = favoriteGenres
        self.location = location
        self.profilePicture = profilePicture
        self.pfpDocName = pfpDocName
        self.blockedUserRefs = blockedUserRefs
        self.cityState = cityState
        self.blockedEventRefs = blockedEventRefs
    }
    
    convenience init?(firestoreDoc data: [String : Any]){
        guard let username = data["username"] as? String,
        let authUserRef = data["authUserRef"] as? String,
        let bio = data["bio"] as? String,
        let lookingFor = data["lookingFor"] as? [String],
        let eventRefs = data["eventRefs"] as? [String],
        let nowPlaying = data["nowPlaying"] as? String,
        let favoriteGames = data["favoriteGames"] as? [String],
        let favoriteGenres = data["favoriteGenres"] as? [String],
        let blockedUsers = data["blockedUsers"] as? [String],
        let cityState = data["cityState"] as? String,
        let blockedEventRefs = data["blockedEventRefs"] as? [String] else {print("couldnt get all of the info we needed from the document. Gonna print it all!"); return nil}
        let pfpDocName = data["pfpDocName"] as? String
        self.init(username: username, authUserRef: authUserRef, eventRefs: eventRefs, conversationRefs: [], bio: bio, nowPlaying: nowPlaying, lookingFor: lookingFor, favoriteGames: favoriteGames, favoriteGenres: favoriteGenres, pfpDocName: pfpDocName, blockedUserRefs: blockedUsers, cityState: cityState)
    }
}
