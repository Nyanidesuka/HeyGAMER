//
//  ConversationViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    //the thing
    var conversation: Conversation?{
        didSet{
            loadViewIfNeeded()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var conversationPartner: User?
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var heyGamerButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 48
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.messageTextView.textColor = .lightGray
        guard let conversation = self.conversation else {return}
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //i would like to refactor this to only take in the uuid of the other user but i'm gonna save things like that for after basic feature are done
    @IBAction func sendButtonPressed(_ sender: Any) {
        print("wow the button got pressed!!!!⚙️⚙️⚙️")
        print(conversationPartner)
        print(UserController.shared.currentUser)
        guard messageTextView.text != "",
            let messageText = messageTextView.text,
            let newMessage = MessageController.shared.createMessage(withText: messageText),
            let userTwo = self.conversationPartner,
            let userOne = UserController.shared.currentUser else {print("failed the first guard");return}
        if let conversation = self.conversation{
            ConversationController.shared.addMessage(toConversation: conversation, message: newMessage)
            self.tableView.reloadData()
            //make sure we move the conversation ref to the front of the array since it now has the most recent activity.
            guard let targetIndex = userOne.conversationRefs.firstIndex(of: conversation.uuid) else {print("failed the second guard"); return}
            userOne.conversationRefs.remove(at: targetIndex)
            userOne.conversationRefs.insert(conversation.uuid, at: 0)
        } else {
            //make a new conversation
            ConversationController.shared.createConversation(initialMessage: newMessage, users: [userOne.authUserRef, userTwo.authUserRef]) { (newConversation) in
                self.conversation = newConversation
                //the didset on conversation will handle the reload in this case
                //make sure we add a ref to this conversation to the user!
                userOne.conversationRefs.insert(newConversation.uuid, at: 0)
                UserController.shared.updateConversationRefs(withNewRef: newConversation.uuid)
                FirebaseService.shared.sendConvoRef(toUser: userTwo, ref: newConversation.uuid)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        self.messageTextView.text = ""
    }
    
    @IBAction func heyGamerButtonPressed(_ sender: Any) {
        
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversation?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellMessage = conversation?.messages[indexPath.row],
        let user = UserController.shared.currentUser else {return UITableViewCell()}
        if cellMessage.username == user.username{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageFromSelf") as? MessageFromSelfTableViewCell else {return UITableViewCell()}
            cell.messageTextLabel.text = cellMessage.text
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageFromOther") as? MessageFromUserTableViewCell else {return UITableViewCell()}
            cell.messageTextLabel.text = cellMessage.text
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.messageTextLabel.layer.cornerRadius = cell.messageTextLabel.frame.height / 2
            return cell
        }
    }
}

extension ConversationViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        print("didChange firing")
        if textView.text == "" || textView.textColor == UIColor.lightGray{
            self.sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        print("endEditing fired")
        if textView.text == ""{
            textView.text = "Message a gamer"
            textView.textColor = .lightGray
            self.sendButton.isEnabled = false
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("beginEditing firing")
        if textView.textColor == UIColor.lightGray{
            textView.text = ""
            textView.textColor = .black
            self.sendButton.isEnabled = false
        }
    }
}
