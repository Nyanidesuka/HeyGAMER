//
//  LocationManager.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/16/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager{
    static let shared = LocationManager()
    var locationManager: CLLocationManager?
}
