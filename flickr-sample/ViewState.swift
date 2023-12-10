//
//  ViewState.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 9/12/23.
//

import Foundation

enum ViewState: Equatable {
    case loading
    case fetching
    case empty
    case deniedLocation
    case stopSharing
    case error(message: String)
}
