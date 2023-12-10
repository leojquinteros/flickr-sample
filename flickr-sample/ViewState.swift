//
//  ViewState.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 9/12/23.
//

import Foundation

enum ViewState {
    case loading
    case fetching
    case empty
    case deniedLocation
    case stopSharing
    case error(message: String)
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case
            (.loading, .loading),
            (.fetching, .fetching),
            (.empty, .empty),
            (.stopSharing, .stopSharing),
            (.deniedLocation, .deniedLocation),
            (.error, .error):
            return true
        default:
            return false
        }
    }
}
