//
//  ContentViewModel.swift
//  komoot-test
//
//  Created by Leo Quinteros on 11/04/23.
//

import Foundation
import Combine
import CoreLocation

private enum Constants: String {
    case FLICKR_API_KEY = "FLICKR_API_KEY"
    case BASE_URL = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
    case PHOTOS_MAX = "1"
    case PHOTOS_FORMAT = "json"
}

class ContentViewModel: NSObject, ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var locationDidChange = PassthroughSubject<CLLocation?, Never>()
    
    var locationManager = CLLocationManager()
    @Published var photos: [FlickrPhoto] = []
    @Published var hasStoppedUpdatingLocation: Bool = false
    @Published var hasDeniedLocation: Bool = false
    
    public init(manager: CLLocationManager = CLLocationManager()) {
        super.init()
        locationManager = manager
        locationManager.delegate = self
        locationManager.distanceFilter = 100
        locationManager.pausesLocationUpdatesAutomatically = false

        locationDidChange
            .removeDuplicates()
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self else {
                    return
                }
                self.fetchNewPhoto(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            .store(in: &cancellables)
    }
    
    var shouldShowStartButton: Bool {
        photos.count == 0 && !hasStoppedUpdatingLocation
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        hasStoppedUpdatingLocation = false
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        hasStoppedUpdatingLocation = true
    }
    
    func setupLocationManager() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            hasDeniedLocation = false
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .denied, .restricted:
            hasDeniedLocation = true
            break
        default:
            break
        }
    }
    
    private func url(lat: CLLocationDegrees, lon: CLLocationDegrees) -> URL? {
        var endpoint = Constants.BASE_URL.rawValue
        endpoint += "&api_key=\(Constants.FLICKR_API_KEY.rawValue)"
        endpoint += "&lat=\(lat)"
        endpoint += "&lon=\(lon)"
        endpoint += "&per_page=\(Constants.PHOTOS_MAX.rawValue)"
        endpoint += "&format=\(Constants.PHOTOS_FORMAT.rawValue)"
        endpoint += "&nojsoncallback=1"
        return URL(string: endpoint)
    }

    private func fetchNewPhoto(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        guard let url = url(lat: latitude, lon: longitude) else {
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: FlickrResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                  break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] result in
                guard let self, let photo = result.photos.photo.first else {
                    return
                }
                if !self.photos.contains(photo) {
                    self.photos.insert(photo, at: 0)
                }
            })
            .store(in: &cancellables)
    }
}
