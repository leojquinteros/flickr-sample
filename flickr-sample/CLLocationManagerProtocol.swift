//
//  CLLocationManagerProtocol.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 7/08/23.
//

import Foundation
import CoreLocation

extension CLLocationManager: CLLocationManagerProtocol {}

protocol CLLocationManagerProtocol {
    var delegate: CLLocationManagerDelegate? { get set }
    var distanceFilter: CLLocationDistance { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var pausesLocationUpdatesAutomatically: Bool { get set }
    var allowsBackgroundLocationUpdates: Bool { get set }
    var authorizationStatus: CLAuthorizationStatus { get }

    func requestAlwaysAuthorization()
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

