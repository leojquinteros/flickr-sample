//
//  PhotosService.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 11/06/23.
//

import Foundation
import Combine

private enum Constants: String {
    case FLICKR_API_KEY = "e25c841985bee61afa0d8481eea85e9e"
    case BASE_URL = "ahttps://www.flickr.com/services/rest/?method=flickr.photos.search"
    case PHOTOS_MAX = "1"
    case PHOTOS_FORMAT = "json"
}

protocol PhotosServiceProtocol {
    func fetch<T: PhotosResponse>(_ type: T.Type, latitude: Double, longitude: Double) -> AnyPublisher<URL?, Error>
}

class FlickrService: PhotosServiceProtocol {
        
    func fetch<T>(_ type: T.Type, latitude: Double, longitude: Double) -> AnyPublisher<URL?, Error> where T: PhotosResponse {
        guard let url = url(latitude: latitude, longitude: longitude) else {
            return Fail(error: APIError.invalidRequestError)
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> Error in
                return APIError.transportError(error)
            }
            .map(\.data)
            .tryMap { data -> FlickrResponse in
                do {
                    return try JSONDecoder().decode(FlickrResponse.self, from: data)
                }
                catch {
                    throw APIError.decodingError(error)
                }
            }
            .map(\.photos.photo.first?.url)
            .eraseToAnyPublisher()
    }
    
    private func url(latitude: Double, longitude: Double) -> URL? {
        var endpoint = Constants.BASE_URL.rawValue
        endpoint += "&api_key=\(Constants.FLICKR_API_KEY.rawValue)"
        endpoint += "&lat=\(latitude)"
        endpoint += "&lon=\(longitude)"
        endpoint += "&per_page=\(Constants.PHOTOS_MAX.rawValue)"
        endpoint += "&format=\(Constants.PHOTOS_FORMAT.rawValue)"
        endpoint += "&nojsoncallback=1"
        return URL(string: endpoint)
    }
}
