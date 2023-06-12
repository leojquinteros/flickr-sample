//
//  PhotosModel.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 11/04/23.
//

import Foundation

protocol PhotosResponse: Decodable {}
protocol SinglePhotoResponse: Decodable, Hashable {}

struct FlickrResponse: PhotosResponse {
    let photos: FlickrPhotos
    let stat: String
}

struct FlickrPhotos: Decodable {
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: SinglePhotoResponse {
    let id: String
    let title: String
    let farm: Int
    let server: String
    let secret: String

    var url: URL? {
        URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")
    }
}
