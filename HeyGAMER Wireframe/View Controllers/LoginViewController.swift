//
//  LoginViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/9/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    //MARK: Outlets

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        guard let email = usernameTextField.text,
            let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            //if result is nil, the sign-in was unsuccessful
            print("Login result: \(result.debugDescription)🦀🦀🦀")
            if let loginResult = result{
                print("henlo, we're firing the segue to the fetch VC.")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "initialFetchVC")
                UIApplication.shared.windows.first?.rootViewController = viewController
                self.performSegue(withIdentifier: "toFetchFromLogin", sender: nil)
            } else {
                //tell them they failed the login
                let loginErrorAlert = UIAlertController(title: "Couldn't log you in.", message: "The e-Mail address and password you entered did not match our records.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Got it.", style: .default, handler: nil)
                loginErrorAlert.addAction(okAction)
                self.present(loginErrorAlert, animated: true)
            }
        }
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot Password?", message: "Enter your e-Mail address below. If it matches an account in our records, we'll send a link to reset your password.", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (field) in
            field.placeholder = "Enter e-Mail address"
        }
        let sendAction = UIAlertAction(title: "Send", style: .default) { (_) in
            //unwrap the email address, send the thing
            guard let emailAddress = forgotPasswordAlert.textFields?[0].text else {return}
            Auth.auth().sendPasswordReset(withEmail: emailAddress, completion: { (error) in
                if let error = error{
                    print("there was an error in \(#function); \(error.localizedDescription)")
                    let errorAlert = UIAlertController(title: "Error", message: "There was a problem sending an e-mail to that address. Please make sure it's been entered correctly and try again.", preferredStyle: .alert)
                    let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
                    errorAlert.addAction(closeAction)
                    self.present(errorAlert, animated: true)
                    return
                }
                let sentAlert = UIAlertController(title: "Sent.", message: "Your password reset link has been set. Please check your e-Mail for the next steps.", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Got it.", style: .default, handler: nil)
                sentAlert.addAction(closeAction)
                self.present(sentAlert, animated: true)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        forgotPasswordAlert.addAction(sendAction)
        forgotPasswordAlert.addAction(cancelAction)
        self.present(forgotPasswordAlert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
