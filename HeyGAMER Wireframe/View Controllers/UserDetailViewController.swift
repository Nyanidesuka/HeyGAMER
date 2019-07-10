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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollableView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //The user whomst's data to display on the page
    var user: User?{
        didSet{
            loadViewIfNeeded()
            DispatchQueue.main.async {
                self.navigationItem.title = self.user?.username
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.navigationItem.backBarButtonItem?.title = "Back"
        // Do any additional setup after loading the view.
    }
    
    func updateCellViews(forCell cell: UserInfoTableViewCell){
        guard let user = self.user else {print("no user has been assigned to this page"); return}
        //gonna build some strings for the other labels
        var lookingForString = ""
        for word in user.lookingFor{
            lookingForString += word
            if word != user.lookingFor.last{
                lookingForString += ", "
            }
        }
        var favoriteGamesString = ""
        for word in user.favoriteGames{
            favoriteGamesString += word
            if word != user.favoriteGames.last{
                favoriteGamesString += ", "
            }
        }
        var favoriteGenresString = ""
        for word in user.favoriteGenres{
            favoriteGenresString += word
            if word != user.favoriteGenres.last{
                favoriteGenresString += ", "
            }
        }
        cell.nowPlayingLabel.text = user.nowPlaying
        cell.lookingForLabel.text = lookingForString
        cell.favoriteGenresLabel.text = favoriteGenresString
        cell.favoriteGamesLabel.text = favoriteGamesString
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue jawn")
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

extension UserDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "basicInfoCell") as? UserInfoTableViewCell else {return UITableViewCell()}
            self.updateCellViews(forCell: cell)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "bioCell") as? UserBioTableViewCell else {return UITableViewCell()}
            cell.bioTextView.text = user?.bio
            return cell
        }
    }
}
