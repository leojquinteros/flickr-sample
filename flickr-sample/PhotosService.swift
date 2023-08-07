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
    case BASE_URL = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
    case PHOTOS_MAX = "1"
    case PHOTOS_FORMAT = "json"
}

protocol PhotosServiceProtocol {
    func fetch<T: PhotosResponse>(_ type: T.Type, latitude: Double, longitude: Double) -> AnyPublisher<URL?, APIError>
}

final class FlickrService: PhotosServiceProtocol {
    
    let cache: NSCache<LocationCustomKey, NSString> = .init()
    
    func fetch<T>(_ type: T.Type, latitude: Double, longitude: Double) -> AnyPublisher<URL?, APIError> where T: PhotosResponse {
        guard let url = url(latitude: latitude, longitude: longitude) else {
            return Fail(error: APIError.invalidRequestError)
                .eraseToAnyPublisher()
        }
        let key = LocationCustomKey(latitude, longitude)
        if let cachedURL = cache.object(forKey: key) {
            return Just(URL(string: cachedURL as String))
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        } else {
            cache.setObject(url.absoluteString as NSString, forKey: key)
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> APIError in
                return APIError.transportError(error)
            }
            .map(\.data)
            .tryMap { data -> FlickrResponse in
                do {
                    return try JSONDecoder().decode(FlickrResponse.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            }
            .compactMap { flickrResponse -> URL? in
                flickrResponse.photos.photo.first?.url
            }
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.unknown
                }
            }
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

final class LocationCustomKey: NSObject {
    let lat: Double
    let long: Double
    
    init(_ lat: Double, _ long: Double) {
        self.lat = lat
        self.long = long
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? LocationCustomKey else {
            return false
        }
        return lat == other.lat && long == other.long
    }
    
    override var hash: Int {
        return long.hashValue ^ long.hashValue
    }
    
}
