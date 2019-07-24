//
//  SignUpViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var gamerTagField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var antiTypoField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.popover = buildLoadingPopover()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    var email: String = ""
    var password: String = ""
    var popover: UIAlertController? = nil
    var gamertag: String = ""
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let popover = self.popover else {return}
        self.present(popover, animated: true)
        guard let gamerTag = gamerTagField.text,
        let email = emailField.text,
            let password = passwordField.text,
        let confirmPassword = antiTypoField.text else {return}
        self.email = email
        self.password = password
        self.gamertag = gamerTag
        if password != confirmPassword{
            let passwordAlert = UIAlertController(title: "Passwords do not match", message: "Please make sure the password is entered identically into both password fields, to be sure your password is set correctly.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Got it.", style: .default, handler: nil)
            passwordAlert.addAction(okAction)
            popover.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.present(passwordAlert, animated: true)
                }
            }
            
            return
        }
        if gamerTag.isEmpty{
            let usernameAlert = UIAlertController(title: "No Username", message: "Please enter a username into the GAMER Tag field.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Got it.", style: .default, handler: nil)
            usernameAlert.addAction(okAction)
            popover.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.present(usernameAlert, animated: true)
                }
            }
            return
        }
        popover.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showTnC", sender: nil)
            }
        }
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func segueToFetchController(){
        print("henlo, we're firing the segue to the fetch VC.")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "initialFetchVC")
        UIApplication.shared.windows.first?.rootViewController = viewController
        self.performSegue(withIdentifier: "toFetchVC", sender: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTnC"{
            guard let destinVC = segue.destination as? TnCViewController else {return}
            destinVC.delegate = self
        }
    }
    

}
extension SignUpViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignUpViewController: TnCViewControllerDelegate{
    func acceptPressed() {
        guard let popover = self.popover else {return}
        self.present(popover, animated: true)
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                let signupErrorAlert = UIAlertController(title: "Error", message: "There was an error registering your account - \(error.localizedDescription)", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
                signupErrorAlert.addAction(closeAction)
                popover.dismiss(animated: true) {
                    DispatchQueue.main.async {
                        self.present(signupErrorAlert, animated: true)
                    }
                }
                return
            }
            guard let userID = Auth.auth().currentUser?.uid else {print("couldnt get the UID"); return}
            let newUser = User(username: self.gamertag, authUserRef: userID)
            let userDict = UserController.shared.createDictionary(fromUser: newUser)
            FirebaseService.shared.addDocument(documentName: userID, collectionName: FirebaseReferenceManager.userCollection, data: userDict, completion: { (success) in
                print("tried to save the user document to firestore. Success: \(success)")
                if success{
                    UserController.shared.currentUser = newUser
                }
                DispatchQueue.main.async {
                    popover.dismiss(animated: true, completion: {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "toFetchFromSignup", sender: nil)
                        }
                    })
                }
            })
        }
    }
}
