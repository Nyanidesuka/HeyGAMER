//
//  UserDetailViewController.swift
//  HeyGAMER Wireframe
//
//  Created by Haley Jones on 7/8/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import MessageUI

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
    @IBOutlet weak var messageUserButton: UIButton!
    @IBOutlet weak var cityStateLabel: UILabel!
    
    
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
            self.messageUserButton.isEnabled = false
            self.messageUserButton.alpha = 0
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.messageUserButton.layer.cornerRadius = self.messageUserButton.frame.height / 2
        self.profileTextView.layer.cornerRadius = 5
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        guard let pageUser = self.user, let currentUser = UserController.shared.currentUser else {return}
        //some handling for after blocking a user. If this user is blocked, pop the VC so we head back to the user list.
        if currentUser.blockedUserRefs.contains(pageUser.authUserRef){
            self.navigationController?.popViewController(animated: true)
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
        self.pfpImageView.image = user.profilePicture
        self.cityStateLabel.text = user.cityState
        for label in labelCollection{
            guard let text = label?.text else {return}
            if text == "-"{
                label?.textColor = .lightGray
            } else {
                label?.textColor = .darkText
            }
        }
    }
    
    @IBAction func blockButtonPressed(_ sender: Any) {
        guard let user = self.user, let currentUser = UserController.shared.currentUser else {return}
        //we're gonna do this with an alert controller.
        let blockReportAlert = UIAlertController(title: "Report or Block User", message: nil, preferredStyle: .alert)
        let blockAction = UIAlertAction(title: "Block", style: .default) { (action) in
            //present one more alert to make sure
            let confirmAlert = UIAlertController(title: "Block \(user.username)?", message: nil, preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //block them here
                UserController.shared.currentUser?.blockedUserRefs.append(user.authUserRef)
                //then update the user
                let userDict = UserController.shared.createDictionary(fromUser: currentUser)
                FirebaseService.shared.addDocument(documentName: currentUser.authUserRef, collectionName: FirebaseReferenceManager.userCollection, data: userDict, completion: { (success) in
                    print("Tried to update the user in firebase. success: \(success)")
                })
                //then get off that VC and back to the user list
                self.navigationController?.popViewController(animated: true)
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            confirmAlert.addAction(yesAction)
            confirmAlert.addAction(noAction)
            self.present(confirmAlert, animated: true)
        }
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            //bring up an alert controller of alert types
            let reportAlert = UIAlertController(title: "Report \(user.username)", message: "Please select a reason for your report", preferredStyle: .alert)
            let harassmentAction = UIAlertAction(title: "Harassment", style: .default, handler: { (_) in
                self.submitReport(reason: "Harassment", forUser: user, fromUser: currentUser)
            })
            let inappropriateAction = UIAlertAction(title: "Inappropriate Content", style: .default, handler: { (_) in
                self.submitReport(reason: "Inappropriate Content", forUser: user, fromUser: currentUser)
            })
            let offensiveAction = UIAlertAction(title: "Offensive Content", style: .default, handler: { (_) in
                self.submitReport(reason: "Offensive Content", forUser: user, fromUser: currentUser)
            })
            let otherAction = UIAlertAction(title: "Other", style: .default, handler: { (_) in
                let otherAlert = UIAlertController(title: "Enter a reason for your report", message: nil, preferredStyle: .alert)
                otherAlert.addTextField(configurationHandler: { (field) in
                    field.placeholder = "Enter a reason for your report"
                })
                let sendAction = UIAlertAction(title: "Send", style: .default, handler: { (_) in
                    guard let reportReason = otherAlert.textFields?.first?.text else {return}
                    self.submitReport(reason: reportReason, forUser: user, fromUser: currentUser)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                otherAlert.addAction(sendAction)
                otherAlert.addAction(cancelAction)
                self.present(otherAlert, animated: true)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            reportAlert.addAction(harassmentAction)
            reportAlert.addAction(inappropriateAction)
            reportAlert.addAction(offensiveAction)
            reportAlert.addAction(otherAction)
            reportAlert.addAction(cancelAction)
            self.present(reportAlert,animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        blockReportAlert.addAction(blockAction)
        blockReportAlert.addAction(reportAction)
        blockReportAlert.addAction(cancelAction)
        self.present(blockReportAlert, animated: true)
    }
    
    func submitReport(reason: String, forUser: User, fromUser: User){
        //send an email to the report email address
        let mailVC = configureMailController(feedback: reason)
        mailVC.setMessageBody("A report from \(fromUser.username) has been submitted, citing \(reason) in the profile of, or messages from, \(forUser.username). Please look into thise matter and resolve it appropriately.", isHTML: false)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailVC, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send message at this time", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(dismissAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
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
                conversation.delegate = destinVC
            } else {
                print("there's no conversation! A new one will be made when the first message is sent.")
                destinVC.conversationPartner = self.user
            }
        }
    }
}

extension UserDetailViewController: MFMailComposeViewControllerDelegate{
    func configureMailController(feedback: String) -> MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["heyGamer.reports@gmail.com"])
        mailComposerVC.setSubject("User or Content Report - Hey GAMER")
        return mailComposerVC
    }
}

