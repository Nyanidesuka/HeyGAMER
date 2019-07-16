//
//  EditProfileViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/15/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollableArea: UIView!
    @IBOutlet weak var nowPlayingField: UITextField!
    @IBOutlet var favoriteGameFields: [UITextField]!
    @IBOutlet var favoriteGenreFields: [UITextField]!
    @IBOutlet var lookingForFields: [UITextField]!
    @IBOutlet weak var gamerTagField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var pfpImageView: UIImageView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    //MARK: Properties
    //we're gonna put the choices for the pickers in these collections:
    var genreChoices: [String] = ["Action", "Adventure", "FPS", "RTS", "MMO", "MOBA", "MMORPG", "RPG", "Tactics RPG", "2D Platformer", "3D Platformer", "Collectathon", "Fighting", "Anime Fighter", "Traditional Fighter", "Platform Fighter", "Simulation", "Dating Sim", "Visual Novel", "Tabletop RPG", "TCG", "Board Games", "LARP", "Racing", "Retro", "Horror", "Living Card Game", "Rhythm", "Arcade", "Mobile", "Souls-like", "Awful Games"]
    var lookingForChoices: [String] = ["Local Multiplayer", "Online Multuplayer", "Events", "Tournaments", "Guildmates", "Teammates", "Friends", "Practice Partners", "Tabletop Groups", "Streamers"]
    
    var pickerValue: String = ""
    //these need to be variables here so i can differentiate between them later on
    let genrePicker = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
    let lookingForPicker = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
    
    //image picker stuff
    var imagePicker: ImagePicker!
    var imageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.scrollView.contentSize = scrollableArea.frame.size
        self.genreChoices.sort()
        self.lookingForChoices.sort()
        self.addPhotoButton.layer.cornerRadius = addPhotoButton.frame.height / 2
        self.updateViews()
    }
    
    //MARK: IBActions
    @IBAction func lookingForTapped(_ sender: UIButton) {
        self.resignFirstResponder()
        presentPickerAlert(withPicker: lookingForPicker, message: "What are you looking for?", senderTag: sender.tag)
    }
    
    @IBAction func genreTapped(_ sender: UIButton) {
        self.resignFirstResponder()
        presentPickerAlert(withPicker: genrePicker, message: "Select a Genre", senderTag: sender.tag)
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        self.imagePicker.present(from: self.view)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        //we need to update the user, then save the profile picture to firebase, then save the user to firebase
        guard let user = UserController.shared.currentUser,
        let username = gamerTagField.text,
        let nowPlaying = nowPlayingField.text else {return}
        var lookingFor: [String] = []
        for label in lookingForFields{
            guard let text = label.text else {return}
            lookingFor.append(text)
        }
        var favoriteGames: [String] = []
        for label in favoriteGameFields{
            guard let text = label.text else {return}
            favoriteGames.append(text)
        }
        var favoriteGenres: [String] = []
        for label in favoriteGenreFields{
            guard let text = label.text else {return}
            favoriteGenres.append(text)
        }
        user.username = username
        user.nowPlaying = nowPlaying
        user.lookingFor = lookingFor
        user.favoriteGenres = favoriteGenres
        user.favoriteGames = favoriteGames
        if imageChanged{
            //if the user has a pfp ref already keep that and if not make a new one
            let pfpRef = user.pfpDocName ?? UUID().uuidString
            //get the image from the imageview and make it into data
            guard let image = pfpImageView.image, let imageData = image.jpegData(compressionQuality: 0.7) else {print("couldn't handle the image properly"); return}
            FirebaseService.shared.addDocument(documentName: pfpRef, collectionName: FirebaseReferenceManager.profilePicCollection, data: ["data" : imageData]) { (success) in
                print("tried to save the photo to firestore. Success: \(success)")
                if success{
                    user.pfpDocName = pfpRef
                    //save the user to firebase
                    let userDict = UserController.shared.createDictionary(fromUser: user)
                    FirebaseService.shared.addDocument(documentName: user.authUserRef, collectionName: FirebaseReferenceManager.userCollection, data: userDict) { (success) in
                        print("tried to save the user to firestore. Success: \(success)")
                    }
                }
            }
        } else {
            //save the user to firebase
            let userDict = UserController.shared.createDictionary(fromUser: user)
            FirebaseService.shared.addDocument(documentName: user.authUserRef, collectionName: FirebaseReferenceManager.userCollection, data: userDict) { (success) in
                print("tried to save the user to firestore. Success: \(success)")
            }
        }
    }
    
    
    
    func presentPickerAlert(withPicker picker: UIPickerView, message: String, senderTag: Int){
        let pickerAlert = UIAlertController(title: message, message: "\n\n\n\n\n\n", preferredStyle: .alert)
        pickerAlert.isModalInPopover = true
        //add it to the alert!
        pickerAlert.view.addSubview(picker)
        picker.delegate = self
        picker.dataSource = self
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            //here we'll grab the value from the picker and set it as the text in the apropriate field.
            DispatchQueue.main.async {
                if picker == self.lookingForPicker{
                    //doing this because outlet collections dont seem to want to stay in order
                    guard let index = self.lookingForFields.firstIndex(where: {$0.tag == senderTag}) else {return}
                    self.lookingForFields[index].text = self.pickerValue
                } else {
                    guard let index = self.favoriteGenreFields.firstIndex(where: {$0.tag == senderTag}) else {return}
                    self.favoriteGenreFields[index].text = self.pickerValue
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            pickerAlert.dismiss(animated: true, completion: nil)
        }
        pickerAlert.addAction(okAction)
        pickerAlert.addAction(cancelAction)
        self.present(pickerAlert, animated: true)
    }
    
    func updateViews(){
        guard let user = UserController.shared.currentUser else {return}
        pfpImageView.image = user.profilePicture
        gamerTagField.text = user.username
        nowPlayingField.text = user.nowPlaying
        bioTextView.text = user.bio
        characterCountLabel.text = "\(self.bioTextView.text.count) / 500"
        if !bioTextView.text.isEmpty{
            bioTextView.textColor = .darkText
        }
        for i in 0...user.lookingFor.count - 1{
            guard let targetField = self.lookingForFields.first(where: {$0.tag == i}) else {return}
            targetField.text = user.lookingFor[i]
        }
        for i in 0...user.favoriteGames.count - 1{
            guard let targetField = self.favoriteGameFields.first(where: {$0.tag == i}) else {print("couldnt get a favorite game"); return}
            targetField.text = user.favoriteGames[i]
        }
        for i in 0...user.favoriteGenres.count - 1{
            guard let targetField = self.favoriteGenreFields.first(where: {$0.tag == i}) else {print("couldnt find favorite genres"); return}
            targetField.text = user.favoriteGenres[i]
        }
    }
}

extension EditProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == lookingForPicker{
            return self.lookingForChoices.count
        } else {
            return self.genreChoices.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == lookingForPicker{
            return self.lookingForChoices[row]
        } else {
            return self.genreChoices[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == lookingForPicker{
            pickerValue = self.lookingForChoices[row]
        } else {
            pickerValue = self.genreChoices[row]
        }
    }
}

extension EditProfileViewController: ImagePickerDelegate{
    func didSelect(image: UIImage?) {
        //if they selected an image,
        if let image = image{
            //set the imageView to the picture we selected
            self.pfpImageView.image = image
            self.imageChanged = true
        }
    }
}

extension EditProfileViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 500{
            while textView.text.count > 500{
                textView.text.removeLast()
            }
        }
        characterCountLabel.text = "\(textView.text.count) / 500"
    }
}
