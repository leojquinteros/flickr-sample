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
    func fetch<T: PhotosResponse>(_ type: T.Type, latitude: Double, longitude: Double) async -> Result<URL?, APIError>
}

final class FlickrService: PhotosServiceProtocol {
    
    private let jsonDecoder: JSONDecoder
    private let cache: NSCache<LocationCustomKey, NSString>
    
    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        self.cache = .init()
    }
    
    func fetch<T>(_ type: T.Type, latitude: Double, longitude: Double) async -> Result<URL?, APIError> where T: PhotosResponse {
        guard let url = url(latitude: latitude, longitude: longitude) else {
            return .failure(.invalidRequestError)
        }
        let key = LocationCustomKey(latitude, longitude)
        if let cachedURL = cache.object(forKey: key) {
            let url = URL(string: cachedURL as String)
            return .success(url)
        } else {
            cache.setObject(url.absoluteString as NSString, forKey: key)
        }
        var data: Data
        do {
            data = try await URLSession.shared.data(from: url).0
        } catch {
            return .failure(.transportError(error))
        }
        var flickrResponse: FlickrResponse
        do {
            flickrResponse = try jsonDecoder.decode(FlickrResponse.self, from: data)
        } catch {
            return .failure(.decodingError(error))
        }
        return .success(flickrResponse.photos.photo.first?.url)
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
