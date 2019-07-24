//
//  TnCViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/24/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class TnCViewController: UIViewController {
    

    @IBOutlet weak var acceptButton: UIButton!
    var delegate: TnCViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.acceptButton.layer.cornerRadius = 5
    }
    
    
    @IBAction func acceptPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.acceptPressed()
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

protocol TnCViewControllerDelegate{
    func acceptPressed()
}
