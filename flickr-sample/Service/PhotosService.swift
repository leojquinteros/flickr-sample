//
//  PhotosService.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 11/06/23.
//

import Foundation

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
    
    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }
    
    func fetch<T>(_ type: T.Type, latitude: Double, longitude: Double) async -> Result<URL?, APIError> where T: PhotosResponse {
        guard let url = url(latitude: latitude, longitude: longitude) else {
            return .failure(.invalidRequestError)
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
