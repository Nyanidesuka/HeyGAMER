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

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func tapGesture(_ sender: Any) {
        self.resignFirstResponder()
    }
    
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let gamerTag = gamerTagField.text,
        let email = emailField.text,
            let password = passwordField.text,
        let confirmPassword = antiTypoField.text else {return}
        if password != confirmPassword{
            let passwordAlert = UIAlertController(title: "Passwords do not match", message: "Please make sure the password is entered identically into both password fields, to be sure your password is set correctly.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Got it.", style: .default, handler: nil)
            passwordAlert.addAction(okAction)
            self.present(passwordAlert, animated: true)
            return
        }
        if gamerTag.isEmpty{
            let usernameAlert = UIAlertController(title: "No Username", message: "Please enter a username into the GAMER Tag field.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Got it.", style: .default, handler: nil)
            usernameAlert.addAction(okAction)
            self.present(usernameAlert, animated: true)
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                let signupErrorAlert = UIAlertController(title: "Error", message: "There was an error registering your account - \(error.localizedDescription)", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
                signupErrorAlert.addAction(closeAction)
                self.present(signupErrorAlert, animated: true)
                return
            }
            guard let userID = Auth.auth().currentUser?.uid else {print("couldnt get the UID"); return}
            let newUser = User(username: gamerTag, authUserRef: userID)
            let userDict = UserController.shared.createDictionary(fromUser: newUser)
            FirebaseService.shared.addDocument(documentName: userID, collectionName: FirebaseReferenceManager.userCollection, data: userDict, completion: { (success) in
                print("tried to save the user document to firestore. Success: \(success)")
                if success{
                    UserController.shared.currentUser = newUser
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toFetchFromSignup", sender: nil)
                }
            })
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SignUpViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
