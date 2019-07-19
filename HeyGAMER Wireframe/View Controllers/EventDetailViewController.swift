//
//  EventDetailViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/18/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

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
            DispatchQueue.main.async {
                self.updateViews()
                self.fetchAttendingUsers {
                }
            }
        }
    }
    var eventHost: User?

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
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func imGoingbuttonPressed(_ sender: Any) {
        
    }
    @IBAction func contactOrEditButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
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
