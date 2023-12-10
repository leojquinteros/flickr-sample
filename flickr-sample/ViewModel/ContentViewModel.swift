//
//  ContentViewModel.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 11/04/23.
//

import Foundation
import Combine
import CoreLocation

@MainActor
class ContentViewModel: NSObject, ObservableObject {
    
    private(set) var cancellables = Set<AnyCancellable>()
    private(set) var locationDidChange = PassthroughSubject<CLLocation?, Never>()
    private var locationManager: CLLocationManagerProtocol
    private var photosService: PhotosServiceProtocol
    private var photosURL: [URL] = []
    
    @Published var state: ViewState = .ready
    
    init(
        locationManager: CLLocationManagerProtocol = CLLocationManager(),
        photosService: PhotosServiceProtocol = FlickrService()
    ) {
        self.photosService = photosService
        self.locationManager = locationManager
        super.init()
        
        setupLocationManager()
        setupLocationSubject()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    private func setupLocationSubject() {
        locationDidChange
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] location in
                Task {
                    await self?.fetch(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        state = .loading
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        state = .stopSharing
    }
    
    public func updateLocationManager() {
        handleStatus(locationManager.authorizationStatus)
    }
    
    private func handleStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            state = .ready
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .denied, .restricted:
            state = .deniedLocation
            break
        default:
            break
        }
    }
    
    private func fetch(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async {
        let response = await photosService.fetch(FlickrResponse.self, latitude: latitude, longitude: longitude)
        switch response {
        case .failure(let error):
            state = .error(message: error.localizedDescription)
        case .success(let url):
            if let url, !photosURL.contains(url) {
                photosURL.insert(url, at: 0)
                state = .loaded(photosURL)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension ContentViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationDidChange.send(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        state = .error(message: error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleStatus(status)
    }
}
