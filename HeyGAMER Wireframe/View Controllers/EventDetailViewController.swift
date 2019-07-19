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
    
    
    var event: Event?
    var attendingUsers: [User] = []
    var eventHost: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func updateViews(){
        guard let event = event, let user = UserController.shared.currentUser else {return}
        if user.authUserRef == event.hostRef{
            self.contactButton.setTitle("Edit", for: .normal)
            self.imGoingButton.isEnabled = false
        }
        self.casualOrCompetitiveImage.image = UIImage(named: event.isCompetitive ? "trophy" : "meeting")
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
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: event.date)
        self.dateLabel.text = dateString
        self.timeLabel.text = timeString
        self.headerImageView.image = event.headerPhoto
        self.headerImageBG.image = event.headerPhoto
    }
    func fetchAttendingUsers(index: Int = 0, completion: @escaping () -> Void){
        guard let event = event else {completion(); return}
        //figure out if we have any of the attending users loaded, and if we do, just stick them in here.
        for user in UserController.shared.loadedUsers{
            if event.attendingUserRefs.contains(where: {$0 == user.authUserRef}){
                event.attendingUsers.append(user)
            }
        }
        //ok so after that we wanna find out what user refs haven't been taken care of, then load those.
        var remainingUserRefs: [String] = []
        for ref in event.attendingUserRefs{
            if !event.attendingUsers.contains(where: {$0.authUserRef == ref}){
                remainingUserRefs.append(ref)
            }
        }
        //ok so now with that new collection, we can fetch the stragglers
        if remainingUserRefs.count > 0{
            fetchUsersFromRefs(refs: remainingUserRefs) {
                DispatchQueue.main.async {
                    self.attendingUsersCollectionView.reloadData()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.attendingUsersCollectionView.reloadData()
            }
        }
    }
    
    func fetchUsersFromRefs(refs: [String], index: Int = 0, completion: @escaping () -> Void){
        FirebaseService.shared.fetchDocument(documentName: refs[index], collectionName: FirebaseReferenceManager.userCollection) { (document) in
            guard let event = self.event, let document = document, let loadedUser = User(firestoreDoc: document) else {return}
            event.attendingUsers.append(loadedUser)
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
        return self.attendingUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.attendingUsersCollectionView.dequeueReusableCell(withReuseIdentifier: "attendingUserCell", for: indexPath) as? UserCollectionViewCell else {return UICollectionViewCell()}
        cell.userImageView.image = self.attendingUsers[indexPath.item].profilePicture
        cell.usernameLabel.text = self.attendingUsers[indexPath.item].username
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)
    }
}
