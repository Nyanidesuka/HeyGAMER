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
    
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        self.imagePicker.present(from: self.view)
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        
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
