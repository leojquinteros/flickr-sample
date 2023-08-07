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
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var locationDidChange = PassthroughSubject<CLLocation?, Never>()

    private var locationManager: CLLocationManager
    private var photosService: PhotosServiceProtocol
 
    @Published var photosURL: [URL] = []
    @Published var hasStoppedUpdatingLocation: Bool = false
    @Published var hasDeniedLocation: Bool = false
    @Published var isLoading: Bool = false
    @Published var isPresentingError: Bool = false
    
    var errorMessage: String = ""
    
    init(
        locationManager: CLLocationManager = CLLocationManager(),
        photosService: PhotosServiceProtocol = FlickrService()
    ) {
        self.photosService = photosService
        self.locationManager = locationManager
        super.init()
        
        setupLocationManager()

        locationDidChange
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.fetch(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            .store(in: &cancellables)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    var shouldShowStartButton: Bool {
        photosURL.count == 0
    }
    
    var restartButtonDisabled: Bool {
        !hasStoppedUpdatingLocation && !hasDeniedLocation
    }
    
    var stopButtonDisabled: Bool {
        hasStoppedUpdatingLocation || hasDeniedLocation
    }
    
    public func startUpdatingLocation() {
        isLoading = true
        isPresentingError = false
        photosURL = []
        hasStoppedUpdatingLocation = false
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        hasStoppedUpdatingLocation = true
    }
    
    func updateLocationManager() {
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

    private func fetch(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        photosService.fetch(FlickrResponse.self, latitude: latitude, longitude: longitude)
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                  break
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.isPresentingError = true
                    return
                }
            }, receiveValue: { [weak self] result in
                guard let self, let result else { return }
                if !self.photosURL.contains(result) {
                    self.photosURL.insert(result, at: 0)
                }
            })
            .store(in: &cancellables)
    }
}

extension ContentViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationDidChange.send(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = APIError.unknown.localizedDescription
        isPresentingError = true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            hasDeniedLocation = false
            break
        case .denied:
            hasDeniedLocation = true
            break
        default:
            break
        }
    }
}
