//
//  UIViewController+Extension.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/23/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

extension UIViewController{
    
    func buildLoadingPopover() -> UIAlertController{
        let loadingPopover = UIAlertController(title: "Just a sec...", message: "\n \n \n \n", preferredStyle: .alert)
//        loadingPopover.isModalInPopover = true
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.color = UIColor.black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingPopover.view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: loadingPopover.view.centerYAnchor, constant: 8),
            activityIndicator.centerXAnchor.constraint(equalTo: loadingPopover.view.centerXAnchor)])
        activityIndicator.startAnimating()
        return loadingPopover
    }
}
