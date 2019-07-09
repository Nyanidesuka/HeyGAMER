//
//  InitialFetchViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class InitialFetchViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //check to see if the user is signed in
        if let user = Auth.auth().currentUser{
            print("we are totally signed in 🦀🦀")
            //Since we are totally signed in, we'll get what data we need and then head to the main view.
            FirebaseService.shared.fetchDocument(documentName: user.uid, collectionName: FirebaseReferenceManager.userCollection) { (userDoc) in
                guard let userDoc = userDoc else {print("couldn't unwrap the user document🦀🦀🦀"); return}
                guard let loadedUser = User(firestoreDoc: userDoc) else {print("couldnt turn the loaded doc into a user🦀🦀🦀 \(userDoc)"); return}
                UserController.shared.currentUser = loadedUser
                print(UserController.shared.currentUser?.username)
                DispatchQueue.main.async {
                    self.segueToTabBarVC()
                }
            }
        } else {
            print("we are totally not signed in🦀🦀")
            //since we're not signed in let's get this GAMER to the login screen
            segueToLoginVC()
        }
    }
    
    func segueToTabBarVC(){
        self.activityIndicator.stopAnimating()
        print("henlo, we're firing the segue to the tab bar controller.")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarController")
        UIApplication.shared.windows.first?.rootViewController = viewController
        self.performSegue(withIdentifier: "toTabBarVC", sender: nil)
    }
    
    func segueToLoginVC(){
        self.activityIndicator.stopAnimating()
        print("henlo, we're firing the segue to the login vc.")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        UIApplication.shared.windows.first?.rootViewController = viewController
        self.performSegue(withIdentifier: "toLoginVC", sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
