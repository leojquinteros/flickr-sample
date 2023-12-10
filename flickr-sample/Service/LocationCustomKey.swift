//
//  LocationCustomKey.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 10/12/23.
//

import Foundation

final class LocationCustomKey: NSObject {
    let lat: Double
    let lon: Double
    
    init(_ lat: Double, _ lon: Double) {
        self.lat = lat
        self.lon = lon
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? LocationCustomKey else {
            return false
        }
        return lat == other.lat && lon == other.lon
    }
    
    override var hash: Int {
        lon.hashValue ^ lon.hashValue
    }
}
