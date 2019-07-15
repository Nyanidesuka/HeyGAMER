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
                //MARK: Set up listeners for conversations
                let collectionRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.userCollection).document(user.uid).collection("conversationRefs")
                collectionRef.addSnapshotListener({ (snappy, error) in
                    print("the snapshot listener for this user's list of conversations has fired. 🐝🐝🐝")
                    //we should add a listener to the new thing, too
                })
                //so the next thing to do is to add a listener into each conversation.
                //so let's get each one first
                collectionRef.getDocuments(completion: { (snapshot, error) in
                    if let error = error{
                        print("there was an error in \(#function); \(error.localizedDescription)")
                        return
                    }
                    guard let snapshot = snapshot else {print("couldn't unwrap the snapshot"); return}
                    for document in snapshot.documents{
                        guard let docName = document.data()["ref"] as? String else {print("couldnt get the string from the document🐝🐝🐝"); return}
                        let docRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.conversationCollection).document(docName)
                        docRef.addSnapshotListener({ (snapshot, error) in
                            if let error = error{
                                print("there was an error in \(#function); \(error.localizedDescription)")
                                return
                            }
                            //here, we would get the messages from that conversation.
                            MessageController.shared.getMessages(withConversationRef: docName, completion: {
                                //we shouldnt have to do anything here but we do need to make sure the table reloads.
                            })
                        })
                    }
                })
                if let pfpRef = loadedUser.pfpDocName{
                    FirebaseService.shared.fetchDocument(documentName: pfpRef, collectionName: FirebaseReferenceManager.profilePicCollection, completion: { (document) in
                        guard let document = document, let imageData = document["data"] as? Data, let profilePic = UIImage(data: imageData) else {return}
                        loadedUser.profilePicture = profilePic
                        DispatchQueue.main.async {
                            self.segueToTabBarVC()
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        self.segueToTabBarVC()
                    }
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
