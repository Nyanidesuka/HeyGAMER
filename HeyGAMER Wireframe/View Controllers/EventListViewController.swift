//
//  EventListViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/18/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class EventListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetail"{
            guard let destinVC = segue.destination as? EventDetailViewController, let index = self.collectionView.indexPathsForSelectedItems?.first else {return}
            destinVC.event = EventController.shared.events[index.item]
        }
    }
}

extension EventListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EventController.shared.events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as? EventCollectionViewCell else {return UICollectionViewCell()}
        let cellEvent = EventController.shared.events[indexPath.item]
        cell.eventNameLabel.text = cellEvent.title
        cell.casualOrCompetitiveImage.image = UIImage(named: cellEvent.isCompetitive ? "trophy" : "meeting")
        cell.labelBackgroundView.layer.cornerRadius = 5
        if let photo = cellEvent.headerPhoto{
            cell.eventImageView.image = photo
        } else {
            guard let photoRef = cellEvent.headerPhotoRef, !photoRef.isEmpty else {return cell}
            FirebaseService.shared.fetchDocument(documentName: photoRef, collectionName: FirebaseReferenceManager.eventPicCollection) { (document) in
                guard let document = document, let data = document["data"] as? Data else {return}
                cell.eventImageView.image = UIImage(data: data)
            }
        }
        
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.width / 2)
    }
    
}
