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
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        print("wow the button got pressed!!!!⚙️⚙️⚙️")
        print(conversationPartner)
        print(UserController.shared.currentUser)
        guard messageTextView.text != "", messageTextView.textColor != UIColor.lightText, let messageText = messageTextView.text, let newMessage = MessageController.shared.createMessage(withText: messageText), let userTwo = self.conversationPartner, let userOne = UserController.shared.currentUser else {print("failed the first guard");return}
        if let conversation = self.conversation{
            ConversationController.shared.addMessage(toConversation: conversation, message: newMessage)
            self.tableView.reloadData()
            //make sure we move the conversation ref to the front of the array since it now has the most recent activity.
            guard let targetIndex = userOne.conversationRefs.firstIndex(of: conversation.uuid) else {print("failed the second guard"); return}
            userOne.conversationRefs.remove(at: targetIndex)
            userOne.conversationRefs.insert(conversation.uuid, at: 0)
            UserController.shared.updateUserDocument()
        } else {
            //make a new conversation
            ConversationController.shared.createConversation(initialMessage: newMessage, users: [userOne.authUserRef, userTwo.authUserRef]) { (newConversation) in
                self.conversation = newConversation
                //the didset on conversation will handle the reload in this case
                //make sure we add a ref to this conversation to the user!
                userOne.conversationRefs.insert(newConversation.uuid, at: 0)
                UserController.shared.updateUserDocument()
                FirebaseService.shared.sendConvoRef(toUser: userTwo, ref: newConversation.uuid)
            }
        }
    }
    
    @IBAction func heyGamerButtonPressed(_ sender: Any) {
        
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

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversation?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension ConversationViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" || textView.textColor == UIColor.lightText{
            self.sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
}
