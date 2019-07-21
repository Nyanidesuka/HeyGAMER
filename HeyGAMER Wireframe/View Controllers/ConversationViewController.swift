//
//  ConversationViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import MessageUI

class ConversationViewController: UIViewController {
    
    //the thing
    var conversation: Conversation?{
        didSet{
            loadViewIfNeeded()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.conversation != nil{
                    self.heyGamerButtonView.alpha = 0
                    self.heyGamerButton.isEnabled = false
                }
            }
        }
    }
    var conversationPartner: User?
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var heyGamerButton: UIButton!
    @IBOutlet weak var heyGamerButtonView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 202
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.messageTextView.textColor = .lightGray
        self.messageTextView.layer.cornerRadius = 4
        self.heyGamerButtonView.layer.cornerRadius = self.heyGamerButtonView.frame.height / 2
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
    
    @IBAction func reportBlockButtonPressed(_ sender: Any) {
        guard let user = self.conversationPartner, let currentUser = UserController.shared.currentUser else {return}
        //we're gonna do this with an alert controller.
        let blockReportAlert = UIAlertController(title: "Report or Block User", message: nil, preferredStyle: .alert)
        let blockAction = UIAlertAction(title: "Block", style: .default) { (action) in
            //present one more alert to make sure
            let confirmAlert = UIAlertController(title: "Block \(user.username)?", message: nil, preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //block them here
                UserController.shared.currentUser?.blockedUserRefs.append(user.authUserRef)
                //then update the user
                let userDict = UserController.shared.createDictionary(fromUser: currentUser)
                FirebaseService.shared.addDocument(documentName: currentUser.authUserRef, collectionName: FirebaseReferenceManager.userCollection, data: userDict, completion: { (success) in
                    print("Tried to update the user in firebase. success: \(success)")
                })
                //then back out of this conversation
                self.navigationController?.popViewController(animated: true)
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            confirmAlert.addAction(yesAction)
            confirmAlert.addAction(noAction)
            self.present(confirmAlert, animated: true)
        }
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            //bring up an alert controller of alert types
            let reportAlert = UIAlertController(title: "Report \(user.username)", message: "Please select a reason for your report", preferredStyle: .alert)
            let harassmentAction = UIAlertAction(title: "Harassment", style: .default, handler: { (_) in
                self.submitReport(reason: "Harassment", forUser: user, fromUser: currentUser)
            })
            let inappropriateAction = UIAlertAction(title: "Inappropriate Content", style: .default, handler: { (_) in
                self.submitReport(reason: "Inappropriate Content", forUser: user, fromUser: currentUser)
            })
            let offensiveAction = UIAlertAction(title: "Offensive Content", style: .default, handler: { (_) in
                self.submitReport(reason: "Offensive Content", forUser: user, fromUser: currentUser)
            })
            let otherAction = UIAlertAction(title: "Other", style: .default, handler: { (_) in
                let otherAlert = UIAlertController(title: "Enter a reason for your report", message: nil, preferredStyle: .alert)
                otherAlert.addTextField(configurationHandler: { (field) in
                    field.placeholder = "Enter a reason for your report"
                })
                let sendAction = UIAlertAction(title: "Send", style: .default, handler: { (_) in
                    guard let reportReason = otherAlert.textFields?.first?.text else {return}
                    self.submitReport(reason: reportReason, forUser: user, fromUser: currentUser)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                otherAlert.addAction(sendAction)
                otherAlert.addAction(cancelAction)
                self.present(otherAlert, animated: true)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            reportAlert.addAction(harassmentAction)
            reportAlert.addAction(inappropriateAction)
            reportAlert.addAction(offensiveAction)
            reportAlert.addAction(otherAction)
            reportAlert.addAction(cancelAction)
            self.present(reportAlert,animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        blockReportAlert.addAction(blockAction)
        blockReportAlert.addAction(reportAction)
        blockReportAlert.addAction(cancelAction)
        self.present(blockReportAlert, animated: true)
    }
    
    func submitReport(reason: String, forUser: User, fromUser: User){
        //send an email to the report email address
        let mailVC = configureMailController(feedback: reason)
        mailVC.setMessageBody("A report from \(fromUser.username) has been submitted, citing \(reason) in the profile of, or messages from, \(forUser.username). Please look into thise matter and resolve it appropriately.", isHTML: false)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailVC, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send message at this time", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(dismissAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
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
            cell.messageBubbleView.layer.cornerRadius = 6
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageFromOther") as? MessageFromUserTableViewCell else {return UITableViewCell()}
            cell.messageTextLabel.text = cellMessage.text
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.messageBubbleView.layer.cornerRadius = 6
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

extension ConversationViewController: ConversationDelegate{
    func updateMessages(forConversation conversation: Conversation) {
        DispatchQueue.main.async {
            self.loadViewIfNeeded()
            self.tableView.reloadData()
        }
    }
}

extension ConversationViewController: MFMailComposeViewControllerDelegate{
    func configureMailController(feedback: String) -> MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["heyGamer.reports@gmail.com"])
        mailComposerVC.setSubject("User or Content Report - Hey GAMER")
        return mailComposerVC
    }
}
