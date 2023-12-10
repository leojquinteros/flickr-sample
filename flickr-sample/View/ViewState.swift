//
//  ViewState.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 9/12/23.
//

import Foundation

enum ViewState: Equatable {
    case loading
    case ready
    case loaded(_ photosURL: [URL])
    case deniedLocation
    case stopSharing
    case error(message: String)
}
