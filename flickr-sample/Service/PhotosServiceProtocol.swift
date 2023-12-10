//
//  PhotosServiceProtocol.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 10/12/23.
//

import Foundation

protocol PhotosServiceProtocol {
    func fetch<T: PhotosResponse>(_ type: T.Type, latitude: Double, longitude: Double) async -> Result<URL?, APIError>
}
