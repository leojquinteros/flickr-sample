//
//  PhotosModel.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 11/04/23.
//

import Foundation

protocol PhotosResponse: Decodable {}
protocol SinglePhotoResponse: Decodable, Hashable {
    var url: URL? { get }
}

struct FlickrResponse: PhotosResponse {
    let photos: FlickrPhotos
    let stat: String
}

struct FlickrPhotos: Decodable {
    let photo: [FlickrPhoto]
}

struct FlickrPhoto {
    let id: String
    let title: String
    let farm: Int
    let server: String
    let secret: String
}

extension FlickrPhoto: SinglePhotoResponse {
    var url: URL? {
        URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")
    }
}

enum APIError: LocalizedError {
    case invalidRequestError
    case transportError(Error)
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidRequestError:
            return "Invalid Request"
        case .transportError(let error):
            return "Transport Error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding Error: \(error.localizedDescription)"
        }
    }
}
