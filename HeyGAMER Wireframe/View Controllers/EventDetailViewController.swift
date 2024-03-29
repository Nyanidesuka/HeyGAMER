//
//  EventDetailViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/18/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import MessageUI

class EventDetailViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var attendingUsersCollectionView: UICollectionView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerImageBG: UIImageView!
    @IBOutlet weak var casualOrCompetitiveImage: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var casualCompetitiveLabel: UILabel!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imGoingButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollableArea: UIView!
    @IBOutlet weak var deletebutton: UIButton!
    
    
    
    var event: Event?{
        didSet{
            loadViewIfNeeded()
            print("photo: \(event?.headerPhoto)")
            DispatchQueue.main.async {
                self.updateViews()
                self.fetchAttendingUsers {
                }
            }
            if event?.host == nil{
                print("event has no loaded host")
                guard let hostRef = event?.hostRef else {return}
                print("but it does have a host ref")
                if let hostUser = UserController.shared.loadedUsers.first(where: {$0.authUserRef == hostRef}){
                    self.event?.host = hostUser
                } else {
                    FirebaseService.shared.fetchDocument(documentName: hostRef, collectionName: FirebaseReferenceManager.userCollection) { (document) in
                        guard let document = document, let loadedUser = User(firestoreDoc: document) else {return}
                        self.event?.host = loadedUser
                    }
                }
            }
        }
    }
    var eventHost: User?{
        return self.event?.host
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = scrollableArea.frame.size
        self.contactButton.layer.cornerRadius = 5
        self.imGoingButton.layer.cornerRadius = 5
        self.deletebutton.layer.cornerRadius = 5
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        guard let event = self.event else {return}
        self.updateViews()
        EventController.shared.fetchUsers(forEvent: event) {
            DispatchQueue.main.async {
                self.attendingUsersCollectionView.reloadData()
            }
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func imGoingbuttonPressed(_ sender: Any) {
        guard let event = self.event, let user = UserController.shared.currentUser else {return}
        if let targetIndex = event.attendingUsers.firstIndex(where: {$0.authUserRef == user.authUserRef}){
            event.attendingUsers.remove(at: targetIndex)
            guard let targetTwo = event.attendingUserRefs.firstIndex(of: user.authUserRef) else {return}
            event.attendingUserRefs.remove(at: targetTwo)
            let eventDict = EventController.shared.createDictionary(fromEvent: event)
            FirebaseService.shared.addDocument(documentName: event.uuid, collectionName: FirebaseReferenceManager.eventsCollection, data: eventDict) { (success) in
                print("tried to update the event in firebase. Success: \(success)")
            }
            self.updateViews()
            self.attendingUsersCollectionView.reloadData()
        } else {
            event.attendingUsers.append(user)
            event.attendingUserRefs.append(user.authUserRef)
            let eventDict = EventController.shared.createDictionary(fromEvent: event)
            FirebaseService.shared.addDocument(documentName: event.uuid, collectionName: FirebaseReferenceManager.eventsCollection, data: eventDict) { (success) in
                print("tried to update the event in firebase. Success: \(success)")
            }
            self.updateViews()
            self.attendingUsersCollectionView.reloadData()
        }
    }
    
    @IBAction func contactOrEditButtonPressed(_ sender: Any) {
        guard let event = event, let user = UserController.shared.currentUser else {return}
        if event.hostRef != user.authUserRef{
            //the user is not the host so we can try to contact the host
            if let host = event.host{
                print("contacting \(host.username)")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "messageHost", sender: nil)
                }
                return
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Couldn't start a conversation with the host. Please try again later.", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "close", style: .default, handler: nil)
                errorAlert.addAction(closeAction)
                self.present(errorAlert, animated: true)
                return
            }
        } else {
            //the user is the host so we're gonna edit the event
            if let host = event.host{
                if host.blockedUserRefs.contains(user.authUserRef) || user.blockedUserRefs.contains(host.authUserRef){
                    let blockedalert = UIAlertController(title: "Error", message: "Unable to contact this user.", preferredStyle: .alert)
                    let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
                    blockedalert.addAction(closeAction)
                    self.present(blockedalert, animated: true)
                    return
                }
            }
            self.performSegue(withIdentifier: "editEvent", sender: nil)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete event?", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            guard let event = self.event, let user = UserController.shared.currentUser else {return}
            if user.eventRefs.contains(event.uuid){
                guard let targetIndex = user.eventRefs.firstIndex(of: event.uuid) else {return}
                user.eventRefs.remove(at: targetIndex)
                let userDict = UserController.shared.createDictionary(fromUser: user)
                FirebaseService.shared.addDocument(documentName: user.authUserRef, collectionName: FirebaseReferenceManager.userCollection, data: userDict, completion: { (success) in
                    print("tried to update the user. success: \(success)")
                })
            }
            if EventController.shared.userEvents.contains(where: {$0.uuid == event.uuid}){
                guard let target = EventController.shared.userEvents.firstIndex(where: {$0.uuid == event.uuid}) else {return}
                EventController.shared.userEvents.remove(at: target)
            }
            if EventController.shared.otherEvents.contains(where: {$0.uuid == event.uuid}){
                guard let target = EventController.shared.otherEvents.firstIndex(where: {$0.uuid == event.uuid}) else {return}
                EventController.shared.otherEvents.remove(at: target)
            }
            let docRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.eventsCollection).document(event.uuid)
            docRef.delete(completion: { (error) in
                if let error = error{
                    print("there was an error in \(#function); \(error.localizedDescription)")
                    return
                } else {
                    print("event deleted🏓🏓🏓 from firebase")
                    //now update the events collection again
                    EventController.shared.fetchEvents {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                        return
                    }
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true)
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        guard let user = UserController.shared.currentUser, let event = self.event else {return}
        let reportOrBlockAlert = UIAlertController(title: "Report or Hide Event", message: nil, preferredStyle: .alert)
        let hideAction = UIAlertAction(title: "Hide", style: .default) { (_) in
            let blockAlert = UIAlertController(title: "Hide this event?", message: "It'll no longer show up in the events tab.", preferredStyle: .alert)
            let blockAction = UIAlertAction(title: "Hide it.", style: .default, handler: { (_) in
                user.blockedEventRefs.append(event.uuid)
                let userDict = UserController.shared.createDictionary(fromUser: user)
                FirebaseService.shared.addDocument(documentName: user.authUserRef, collectionName: FirebaseReferenceManager.userCollection, data: userDict, completion: { (success) in
                    print("tried to update the user in firestore. Success: \(success)")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            blockAlert.addAction(blockAction)
            blockAlert.addAction(cancelAction)
            self.present(blockAlert, animated: true)
        }
        let reportAction = UIAlertAction(title: "Report", style: .default) { (_) in
            let reportAlert = UIAlertController(title: "Report \(event.title)", message: "Please select a reason for your report", preferredStyle: .alert)
            let harassmentAction = UIAlertAction(title: "Harassment", style: .default, handler: { (_) in
                self.submitReport(reason: "Harassment", forEvent: event, fromUser: user)
            })
            let inappropriateAction = UIAlertAction(title: "Inappropriate Content", style: .default, handler: { (_) in
                self.submitReport(reason: "Inappropriate Content", forEvent: event, fromUser: user)
            })
            let offensiveAction = UIAlertAction(title: "Offensive Content", style: .default, handler: { (_) in
                self.submitReport(reason: "Offensive Content", forEvent: event, fromUser: user)
            })
            let otherAction = UIAlertAction(title: "Other", style: .default, handler: { (_) in
                let otherAlert = UIAlertController(title: "Enter a reason for your report", message: nil, preferredStyle: .alert)
                otherAlert.addTextField(configurationHandler: { (field) in
                    field.placeholder = "Enter a reason for your report"
                })
                let sendAction = UIAlertAction(title: "Send", style: .default, handler: { (_) in
                    guard let reportReason = otherAlert.textFields?.first?.text else {return}
                    self.submitReport(reason: reportReason, forEvent: event, fromUser: user)
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
        reportOrBlockAlert.addAction(hideAction)
        reportOrBlockAlert.addAction(reportAction)
        reportOrBlockAlert.addAction(cancelAction)
        self.present(reportOrBlockAlert, animated: true)
    }
    
    func submitReport(reason: String, forEvent: Event, fromUser: User){
        //send an email to the report email address
        let mailVC = configureMailController(feedback: reason)
        mailVC.setMessageBody("A report from \(fromUser.username) has been submitted, citing \(reason) in the event \(forEvent.title). Please look into thise matter and resolve it appropriately.", isHTML: false)
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
    
    
    
    func updateViews(){
        guard let event = event, let user = UserController.shared.currentUser else {return}
        if user.authUserRef == event.hostRef{
            self.contactButton.setTitle("Edit", for: .normal)
            self.imGoingButton.isEnabled = false
        } else {
            self.deletebutton.isEnabled = false
            self.deletebutton.alpha = 0
        }
        if event.attendingUserRefs.contains(where: {$0 == user.authUserRef}){
            self.imGoingButton.setTitle("Not going", for: .normal)
        } else {
            self.imGoingButton.setTitle("I'm going", for: .normal)
        }
        self.casualOrCompetitiveImage.image = UIImage(named: event.isCompetitive ? "trophy" : "meeting")
        self.casualCompetitiveLabel.text = event.isCompetitive ? "Competitive" : "Casual"
        self.eventNameLabel.text = event.title
        self.gameNameLabel.text = event.game
        self.venueNameLabel.text = event.venue
        self.addressLabel.text = event.address
        self.cityStateLabel.text = event.state
        //let's do some date stuff
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: event.date)
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeString = formatter.string(from: event.date)
        self.dateLabel.text = dateString
        self.timeLabel.text = timeString
        self.headerImageView.image = event.headerPhoto ?? UIImage(named: "noImage")
        self.headerImageBG.image = event.headerPhoto ?? UIImage(named: "noImage")
    }
    func fetchAttendingUsers(index: Int = 0, completion: @escaping () -> Void){
        print("the event has \(event?.attendingUserRefs.count) users")
        guard let event = event else {completion(); return}
        //figure out if we have any of the attending users loaded, and if we do, just stick them in here.
        for user in UserController.shared.loadedUsers{
            if event.attendingUserRefs.contains(where: {$0 == user.authUserRef}) && !event.attendingUsers.contains(where: {$0.authUserRef == user.authUserRef}){
                event.attendingUsers.append(user)
            }
        }
        print("after taking from the users we already have, we have \(event.attendingUsers.count) users.")
        //ok so after that we wanna find out what user refs haven't been taken care of, then load those.
        var remainingUserRefs: [String] = []
        for ref in event.attendingUserRefs{
            if !event.attendingUsers.contains(where: {$0.authUserRef == ref}){
                remainingUserRefs.append(ref)
            }
        }
        print("there are \(remainingUserRefs.count) refs remaining")
        //ok so now with that new collection, we can fetch the stragglers
        if remainingUserRefs.count > 0{
            fetchUsersFromRefs(refs: remainingUserRefs) {
                if event.attendingUsers.contains(where: {$0.authUserRef == event.hostRef}){
                    guard let host = event.attendingUsers.first(where: {$0.authUserRef == event.hostRef}) else {return}
                    event.host = host
                }
                DispatchQueue.main.async {
                    self.attendingUsersCollectionView.reloadData()
                }
            }
        } else {
            if event.attendingUsers.contains(where: {$0.authUserRef == event.hostRef}){
                guard let host = event.attendingUsers.first(where: {$0.authUserRef == event.hostRef}) else {return}
                event.host = host
            }
            DispatchQueue.main.async {
                self.attendingUsersCollectionView.reloadData()
            }
        }
    }
    
    func fetchUsersFromRefs(refs: [String], index: Int = 0, completion: @escaping () -> Void){
        FirebaseService.shared.fetchDocument(documentName: refs[index], collectionName: FirebaseReferenceManager.userCollection) { (document) in
            guard let event = self.event, let document = document, let loadedUser = User(firestoreDoc: document) else {return}
            if !event.attendingUsers.contains(where: {$0.authUserRef == loadedUser.authUserRef}){
                event.attendingUsers.append(loadedUser)
            }
            if event.attendingUsers.count < event.attendingUserRefs.count{
                self.fetchUsersFromRefs(refs: refs, index: index + 1, completion: completion)
            } else {
                completion()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageHost"{
            print("in the segue")
            guard let destinVC = segue.destination as? ConversationViewController else {return}
            print("past guard one")
            if let host = self.eventHost{
                if let conversation = ConversationController.shared.conversations.first(where: {$0.userRefs.contains(host.authUserRef)}){
                    //so if we get here, we know these two are already talkin.
                    print("there's a conversation! we are gonna pass it in.")
                    destinVC.conversation = conversation
                    destinVC.conversationPartner = host
                } else {
                    print("there's no conversation! A new one will be made when the first message is sent.")
                    destinVC.conversationPartner = host
                }
            }
        } else if segue.identifier == "editEvent"{
            guard let destinVC = segue.destination as? AddEventViewController else {return}
            destinVC.event = self.event
        }
    }
}

extension EventDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let event = self.event else {return 0}
        print("\(event.attendingUsers.count) cells")
        return event.attendingUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.attendingUsersCollectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as? UserCollectionViewCell, let event = self.event else {return UICollectionViewCell()}
        print("\(event.attendingUsers.count) totla attending users; trying to load user \(indexPath.item) - \(event.attendingUsers[indexPath.item].username)")
        let cellUser = event.attendingUsers[indexPath.item]
        if let image = cellUser.profilePicture{
            cell.userImageView.image = image
        } else {
            if let pfpDocName = cellUser.pfpDocName{
                FirebaseService.shared.fetchDocument(documentName: pfpDocName, collectionName: FirebaseReferenceManager.profilePicCollection) { (document) in
                    guard let document = document, let data = document["data"] as? Data, let image = UIImage(data: data) else {return}
                    cellUser.profilePicture = image
                    cell.userImageView.image = image
                }
            } else {
                cell.userImageView.image = UIImage(named: "noImage")
            }
        }
        cell.usernameLabel.text = event.attendingUsers[indexPath.item].username
        cell.labelBGView.layer.cornerRadius = 5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.8, height: collectionView.frame.height)
    }
}

extension EventDetailViewController: MFMailComposeViewControllerDelegate{
    func configureMailController(feedback: String) -> MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["heyGamer.reports@gmail.com"])
        mailComposerVC.setSubject("User or Content Report - Hey GAMER")
        return mailComposerVC
    }
}
