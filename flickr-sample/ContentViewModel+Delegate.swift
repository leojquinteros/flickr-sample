//
//  ContentViewModel+Delegate.swift
//  komoot-test
//
//  Created by Leo Quinteros on 12/04/23.
//

import Foundation
import CoreLocation

extension ContentViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationDidChange.send(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // error handling
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            hasDeniedLocation = false
            break
        case .denied:
            hasDeniedLocation = true
            break
        default:
            break
        }
    }
}
