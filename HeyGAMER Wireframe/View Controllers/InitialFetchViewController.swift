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
import CoreLocation

class InitialFetchViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.loadingMessageLabel.text = "Authenticating..."
        //check to see if the user is signed in
        if let user = Auth.auth().currentUser{
            self.loadingMessageLabel.text = "Loading user data..."
            print("we are totally signed in 🦀🦀")
            //Since we are totally signed in, we'll get what data we need and then head to the main view.
            FirebaseService.shared.fetchDocument(documentName: user.uid, collectionName: FirebaseReferenceManager.userCollection) { (userDoc) in
                guard let userDoc = userDoc else {print("couldn't unwrap the user document🦀🦀🦀"); return}
                guard let loadedUser = User(firestoreDoc: userDoc) else {print("couldnt turn the loaded doc into a user🦀🦀🦀 \(userDoc)"); return}
                UserController.shared.currentUser = loadedUser
                print(UserController.shared.currentUser?.username)
                //MARK: Set up listeners for conversations
                DispatchQueue.main.async{
                    self.loadingMessageLabel.text = "Reticulating Splines..."
                }
                let collectionRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.userCollection).document(user.uid).collection("conversationRefs")
                collectionRef.addSnapshotListener({ (snappy, error) in
                    print("the snapshot listener for this user's list of conversations has fired. 🐝🐝🐝")
                    //we should add a listener to the new conversation, too
                    guard let snapshot = snappy else {return}
                    for document in snapshot.documents{
                        guard let ref = document.data()["ref"] as? String, let user = UserController.shared.currentUser else {return}
                        if !user.conversationRefs.contains(ref){
                            //ok! after all that, we've found the new conversation. So, we're going to:
                            //add the ref to the user's refs
                            user.conversationRefs.insert(ref, at: 0)
                            //add a listener to the conversation
                            let docRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.conversationCollection).document(ref)
                            docRef.addSnapshotListener({ (snapshot, error) in
                                if let error = error{
                                    print("there was an error in \(#function); \(error.localizedDescription)")
                                    return
                                }
                                //do the same thing here as you'd do in the observer for other conversations
                                //which is like, check if the conversation exists, if it does, add the messages, etc
                                //💈💈💈💈💈💈💈💈💈💈💈💈💈💈💈💈
                                MessageController.shared.getMessages(withConversationRef: ref, completion: {
                                    print("completion of a message update ✲✲✲✲✲✲✲✲🏓")
                                })
                            })
                            //and pull the conversation
                            docRef.getDocument(completion: { (document, error) in
                                if let error = error{
                                    print("there was an error in \(#function); \(error.localizedDescription)")
                                    return
                                }
                                guard let data = document?.data(), let loadedConversation = Conversation(firebaseDocument: data), !ConversationController.shared.conversations.contains(where: {$0.uuid == loadedConversation.uuid}) else {return}
                                ConversationController.shared.conversations.insert(loadedConversation, at: 0)
                            })
                        }
                    }
                })
                //so the next thing to do is to add a listener into each conversation. Maybe? Let's see.
                //so let's get each one first
                collectionRef.getDocuments(completion: { (snapshot, error) in
                    DispatchQueue.main.async{
                        self.loadingMessageLabel.text = "Finding more loading messages..."
                    }
                    if let error = error{
                        print("there was an error in \(#function); \(error.localizedDescription)")
                        return
                    }
                    guard let snapshot = snapshot else {print("couldn't unwrap the snapshot"); return}
                    for document in snapshot.documents{
                        DispatchQueue.main.async {
                            self.loadingMessageLabel.text = "Constructing advanced units..."
                        }
                        guard let docName = document.data()["ref"] as? String else {print("couldnt get the string from the document🐝🐝🐝"); return}
                        //actully add that reference to the user's thing
                        if !loadedUser.conversationRefs.contains(where: {$0 == docName}){
                            print("adding conversation ref to the user")
                            loadedUser.conversationRefs.append(docName)
                        }
                        //apparently i dont need this whole block so let's... leave it here til i realize why i do need it
//                        docRef.addSnapshotListener({ (snapshot, error) in
//                            if let error = error{
//                                print("there was an error in \(#function); \(error.localizedDescription)")
//                                return
//                            }
//                            print("A converation snapshot listener fired, likely because a new message was added.🧲🧲🧲")
//                            //here, we would get the messages from that conversation.
//                            MessageController.shared.getMessages(withConversationRef: docName, completion: {
//                                //we shouldnt have to do anything here but we do need to make sure the table reloads.
//                                print("completion of a message update ✲✲✲✲✲✲✲✲🥎")
//                            })
//                        })
                    }
                    //And then finally we actually load the conversations
                    //MARK: load conversations
                    ConversationController.shared.fetchUserConversations(completion: {
                        DispatchQueue.main.async {
                            self.loadingMessageLabel.text = "Shuffling the deck"
                        }
                        //load events
                        EventController.shared.fetchEvents {
                            DispatchQueue.main.async {
                                self.loadingMessageLabel.text = "Rising up"
                            }
                            //AND THEN we load the profile pic.
                            if let pfpRef = loadedUser.pfpDocName{
                                DispatchQueue.main.async {
                                    self.loadingMessageLabel.text = "Pressing Start"
                                }
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
                    })
                })
            }
        } else {
            print("we are totally not signed in🦀🦀")
            //since we're not signed in let's get this GAMER to the login screen
            segueToLoginVC()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
}
