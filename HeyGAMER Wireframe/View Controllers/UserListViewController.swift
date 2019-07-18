//
//  UserListViewController.swift
//  HeyGAMER Wireframe
//
//  Created by Haley Jones on 7/8/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class UserListViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //SSoT
    var loadedUsers: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //FIRST THING WE DO is ask for that sweet sweet location permission
        //core location request
        LocationManager.shared.locationManager = CLLocationManager()
        LocationManager.shared.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == CLAuthorizationStatus.notDetermined{
            LocationManager.shared.locationManager?.requestWhenInUseAuthorization()
            print("we do not have permissions.⚠️⚠️⚠️⚠️⚠️⚠️⚠️")
        } else {
            print("we have permissions. ⚠️⚠️⚠️⚠️⚠️⚠️")
            if LocationManager.shared.locationManager?.location == nil{
                LocationManager.shared.locationManager?.startUpdatingLocation()
            }
        }
        LocationManager.shared.locationManager?.delegate = self
        FirebaseService.shared.fetchCollection(collectionName: "Users") { (snapshot) in
            guard let snapshot = snapshot else {print("couldn't unwrap the snap"); return}
            let documents = snapshot.documents
            for document in documents{
                guard let loadedUser = User(firestoreDoc: document.data()), let userID = Auth.auth().currentUser?.uid else {print("couldn't make a user from the document"); return}
                print("Loaded user: \(loadedUser.username) 🔋🔋")
                if loadedUser.authUserRef != userID{
                    print("Adding them to the SoT")
                    self.loadedUsers.append(loadedUser)
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            print("henlo, we're firing the segue to the fetch VC.")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "initialFetchVC")
            UIApplication.shared.windows.first?.rootViewController = viewController
            self.performSegue(withIdentifier: "logOut", sender: nil)
        }catch{
            print(error)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserDetail"{
            guard let destinVC = segue.destination as? UserDetailViewController, let index = self.collectionView.indexPathsForSelectedItems?.first else {return}
            if index.item > 0{
                let passUser = self.loadedUsers[index.item - 1]
                destinVC.user = passUser
            } else {
                destinVC.user = UserController.shared.currentUser
                destinVC.userIsSelf = true
            }
        }
    }
}

extension UserListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.loadedUsers.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as? UserCollectionViewCell else {return UICollectionViewCell()}
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        if indexPath != IndexPath(row: 0, section: 0){
            cell.userImageView.image = UIImage(named: "luigiSprite")
            //we have to take 1 off of item because we're reserving that first cell to be the current user.
            cell.usernameLabel.text = self.loadedUsers[indexPath.item - 1].username
        } else {
            cell.userImageView.image = UIImage(named: "marioSprite")
            cell.usernameLabel.text = UserController.shared.currentUser?.username
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)
    }
}

extension UserListViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("the location manager updated the location. 🔪🔪🔪")
    }
}
