//
//  ConversationsViewController.swift
//  HeyGAMER Wireframe
//
//  Created by Haley Jones on 7/8/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class ConversationListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
        self.setNeedsStatusBarAppearanceUpdate()
        for conversation in ConversationController.shared.conversations{
            conversation.delegate = self
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toConversation",
            let index = self.tableView.indexPathForSelectedRow,
            let destinVC = segue.destination as? ConversationViewController else {return}
        destinVC.conversation = ConversationController.shared.conversations[index.row]
        guard let cell = tableView.cellForRow(at: index) as? ConversationTableViewCell else {return}
        destinVC.navigationItem.title = cell.usernameLabel.text
        destinVC.conversationPartner = cell.user
        ConversationController.shared.conversations[index.row].delegate = destinVC
    }
}

extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConversationController.shared.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell") as? ConversationTableViewCell else {return UITableViewCell()}
        let conversation = ConversationController.shared.conversations[indexPath.row]
        //get the user that you're talking to so we can get their picture and username
        guard let user = UserController.shared.currentUser, let userID = conversation.userRefs.first(where: {$0 != user.authUserRef}) else {return UITableViewCell()}
        FirebaseService.shared.fetchDocument(documentName: userID, collectionName: FirebaseReferenceManager.userCollection) { (document) in
            guard let document = document, let otherUser = User(firestoreDoc: document) else {return}
            DispatchQueue.main.async{
                cell.usernameLabel.text = otherUser.username
                cell.user = otherUser
            }
            if let picref = otherUser.pfpDocName{
                FirebaseService.shared.fetchDocument(documentName: picref, collectionName: FirebaseReferenceManager.profilePicCollection, completion: { (document) in
                    guard let document = document, let imageData = document["data"] as? Data else {return}
                    DispatchQueue.main.async {
                        cell.userImageView.image = UIImage(data: imageData)
                    }
                })
            }
        }
        //format the date bb
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        var dateString = ""
        if Date().timeIntervalSince(conversation.messages[0].timestamp) >= 120{
            dateString = formatter.string(from: conversation.messages[0].timestamp)
        } else {
            dateString = "Just now!"
        }
        
        cell.timestampLabel.text = dateString
        cell.recentMessageLabel.text = conversation.messages[0].text
        return cell
    }
}

extension ConversationListViewController: ConversationDelegate{
    func updateMessages(forConversation conversation: Conversation) {
        //move the updated conversation to the top of the conversation list
        if let targetIndex = ConversationController.shared.conversations.firstIndex(where: {$0.uuid == conversation.uuid}){
            ConversationController.shared.conversations.remove(at: targetIndex)
            ConversationController.shared.conversations.insert(conversation, at: 0)
        }
        DispatchQueue.main.async {
            self.loadViewIfNeeded()
            self.tableView.reloadData()
        }
    }
}
