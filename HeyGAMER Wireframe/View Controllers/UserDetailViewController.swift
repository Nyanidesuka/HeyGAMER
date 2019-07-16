//
//  UserDetailViewController.swift
//  HeyGAMER Wireframe
//
//  Created by Haley Jones on 7/8/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {
    //MARK: Outlets

    @IBOutlet weak var scrollableView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var lookingForLabel: UILabel!
    @IBOutlet weak var favoriteGamesLabel: UILabel!
    @IBOutlet weak var favoriteGenresLabel: UILabel!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var pfpImageView: UIImageView!
    
    //The user whomst's data to display on the page
    var user: User?{
        didSet{
            loadViewIfNeeded()
            DispatchQueue.main.async {
                self.navigationItem.title = self.user?.username
                self.updateViews()
            }
        }
    }
    var userIsSelf = false{
        didSet{
            loadViewIfNeeded()
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.image = nil
            self.navigationItem.rightBarButtonItem?.title = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        // Do any additional setup after loading the view.
    }
    
    func updateViews(){
        guard let user = self.user else {print("no user has been assigned to this page"); return}
        //gonna build some strings for the other labels
        var lookingForString = ""
        for word in user.lookingFor{
            lookingForString += word
            if word != user.lookingFor.last{
                lookingForString += ", "
            }
        }
        lookingForString = lookingForString.isEmpty ? "-" : lookingForString
        var favoriteGamesString = ""
        for word in user.favoriteGames{
            favoriteGamesString += word
            if word != user.favoriteGames.last{
                favoriteGamesString += ", "
            }
        }
        favoriteGamesString = favoriteGamesString.isEmpty ? "-" : favoriteGamesString
        var favoriteGenresString = ""
        for word in user.favoriteGenres{
            favoriteGenresString += word
            if word != user.favoriteGenres.last{
                favoriteGenresString += ", "
            }
        }
        favoriteGenresString = favoriteGenresString.isEmpty ? "-" : favoriteGenresString
        self.nowPlayingLabel.text = user.nowPlaying.isEmpty ? "-" : user.nowPlaying
        self.favoriteGamesLabel.text = favoriteGamesString
        self.lookingForLabel.text = lookingForString
        self.favoriteGenresLabel.text = favoriteGenresString
        self.profileTextView.text = user.bio
        let labelCollection = [nowPlayingLabel, lookingForLabel, favoriteGamesLabel, favoriteGenresLabel]
        for label in labelCollection{
            guard let text = label?.text else {return}
            if text == "-"{
                label?.textColor = .lightGray
            } else {
                label?.textColor = .darkText
            }
        }
        self.pfpImageView.image = user.profilePicture
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageUser"{
            print("in the segue")
            guard let destinVC = segue.destination as? ConversationViewController, let user = self.user else {return}
            print("past the guard")
            //let's find out if there's already a conversation between these two; if there's not, we'll make one.
            if let conversation = ConversationController.shared.conversations.first(where: {$0.userRefs.contains(user.authUserRef)}){
                //so if we get here, we know these two are already talkin.
                print("there's a conversation! we are gonna pass it in.")
                destinVC.conversation = conversation
                destinVC.conversationPartner = user
            } else {
                print("there's no conversation! A new one will be made when the first message is sent.")
                destinVC.conversationPartner = self.user
            }
            destinVC.navigationItem.title = ""
        }
    }
}


