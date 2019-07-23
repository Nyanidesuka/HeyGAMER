//
//  AddEventViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/18/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class AddEventViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollableArea: UIView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var evemtImageView: UIImageView!
    @IBOutlet weak var eventTitleField: UITextField!
    @IBOutlet weak var casualOrCompetitiveField: UITextField!
    @IBOutlet weak var casualOrCompetitiveImage: UIImageView!
    @IBOutlet weak var gameTitleField: UITextField!
    @IBOutlet weak var venueNameLabel: UITextField!
    @IBOutlet weak var streetAddressField: UITextField!
    @IBOutlet weak var cityStateField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var headerBackgroundView: UIImageView!
    
    //MARK: Landing Pad
    var event: Event?{
        didSet{
            loadViewIfNeeded()
            DispatchQueue.main.async {
                self.updateViews()
                self.navigationItem.rightBarButtonItem?.title = "Save"
            }
        }
    }
    //image picker stuff
    var imagePicker: ImagePicker!
    var imageChanged = false
    
    //picker alert stuff
    var pickerValue: String = ""
    let anPicker = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
    let pickerChoices = ["Casual", "Competitive"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = scrollableArea.frame.size
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.datePicker.backgroundColor = .white
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
    
    
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        self.imagePicker.present(from: self.view)
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        let popover = buildLoadingPopover()
        self.present(popover, animated: true)
        //get all the info from the fields
        guard let eventName = self.eventTitleField.text,
        let game = gameTitleField.text,
        let competitiveString = casualOrCompetitiveField.text,
        !competitiveString.isEmpty,
        let venueName = venueNameLabel.text,
        let address = streetAddressField.text,
        let cityState = cityStateField.text,
        let user = UserController.shared.currentUser else {return}
        let isCompetitive = competitiveString == "Competitive" ? true : false
        var photoRef: String? = nil
        if let image = self.evemtImageView.image{
            photoRef = UUID().uuidString
        }
        //now we decide whether to make a new event or update a current event.
        if let event = self.event{
            print("updating an event🙌🙌🙌🙌")
            event.title = eventName
            event.game = game
            event.isCompetitive = isCompetitive
            event.venue = venueName
            event.address = address
            event.state = cityState
            if imageChanged{
                //delete the old image doc
                if let photoRef = event.headerPhotoRef{
                    print("deleting the old image doc")
                    let docRef = FirebaseReferenceManager.root.collection(FirebaseReferenceManager.eventPicCollection).document(photoRef)
                    docRef.delete()
                }
                if let image = evemtImageView.image{
                    print("setting a new photo ref")
                    let newPhotoRef = UUID().uuidString
                    event.headerPhotoRef = newPhotoRef
                    event.headerPhoto = image
                    EventController.shared.saveEventPhoto(image: image, forEvent: event)
                }
            }
            EventController.shared.updateEvent(event: event)
            DispatchQueue.main.async {
                popover.dismiss(animated: true, completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
            
        } else {
            EventController.shared.createNewEvent(title: eventName, date: datePicker.date, hostRef: user.authUserRef, state: cityState, venue: venueName, openToAnyone: true, isCompetitive: isCompetitive, headerPhotoRef: photoRef, attendingUserRefs: [user.authUserRef], game: game, address: address) {(newEvent) in
                if let image = self.evemtImageView.image{
                    print("there's an image in the imageView so we're gonna try and save that mf👚👚👚")
                    EventController.shared.saveEventPhoto(image: image, forEvent: newEvent)
                }
                DispatchQueue.main.async {
                    popover.dismiss(animated: true, completion: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
    
    @IBAction func casualCompetitiveButtonTapped(_ sender: Any) {
        presentPickerAlert(withPicker: anPicker, message: "Event Style")
    }
    
    func updateViews(){
        guard let event = event else {return}
        self.evemtImageView.image = event.headerPhoto
        self.eventTitleField.text = event.title
        self.casualOrCompetitiveField.text = event.isCompetitive ? "Competitive" : "Casual"
        self.gameTitleField.text = event.game
        self.venueNameLabel.text = event.venue
        self.streetAddressField.text = event.address
        self.cityStateField.text = event.state
        self.datePicker.date = event.date
        self.headerBackgroundView.image = event.headerPhoto
    }
    
    func presentPickerAlert(withPicker picker: UIPickerView, message: String){
        let pickerAlert = UIAlertController(title: message, message: "\n\n\n\n\n\n", preferredStyle: .alert)
        pickerAlert.isModalInPopover = true
        //add it to the alert!
        pickerAlert.view.addSubview(picker)
        picker.delegate = self
        picker.dataSource = self
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            //here we'll grab the value from the picker and set it as the text in the apropriate field.
            DispatchQueue.main.async {
                self.casualOrCompetitiveField.text = self.pickerValue
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            pickerAlert.dismiss(animated: true, completion: nil)
        }
        pickerAlert.addAction(okAction)
        pickerAlert.addAction(cancelAction)
        self.present(pickerAlert, animated: true)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "savedEvent"{
            guard let destinVC = segue.destination as? EventDetailViewController, let event = self.event else {return}
            destinVC.event = event
        }
    }
}

extension AddEventViewController: ImagePickerDelegate{
    func didSelect(image: UIImage?) {
        //if they selected an image,
        if let image = image{
            //set the imageView to the picture we selected
            self.headerBackgroundView.image = image
            self.evemtImageView.image = image
            self.imageChanged = true
        }
    }
}

extension AddEventViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerChoices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerValue = pickerChoices[row]
        self.casualOrCompetitiveImage.image = UIImage(named: pickerChoices[row] == "Competitive" ? "trophy" : "meeting")
    }
}

extension AddEventViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
