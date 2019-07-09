//
//  UserController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation

class UserController{
    
    static let shared = UserController()
    var currentUser: User?
    
    func createDictionary(fromUser user: User) -> [String : Any]{
        let returnDict: [String : Any] = ["username" : user.username, "conversationRefs" : user.conversationRefs, "eventRefs" : user.eventRefs, "bio" : user.bio, "nowPlaying" : user.nowPlaying, "lookingFor" : user.lookingFor, "favoriteGames" : user.favoriteGames, "favoriteGenres" : user.favoriteGenres, "pfpDocName" : user.pfpDocName, "authUserRef" : user.authUserRef]
        return returnDict
    }
    
}
