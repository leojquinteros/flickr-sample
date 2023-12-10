//
//  ContentViewModelTests.swift
//  flickr-sampleTests
//
//  Created by Leo Quinteros on 7/08/23.
//

import XCTest
import Combine
import CoreLocation
@testable import flickr_sample

@MainActor class ContentViewModelTests: XCTestCase {
    
    var viewModel: ContentViewModel!
    var locationManagerMock: CLLocationManagerMock!
    var photosServiceMock: FlickrServiceMock!
    
    override func setUp() {
        super.setUp()
        locationManagerMock = CLLocationManagerMock()
        photosServiceMock = FlickrServiceMock()
        
        viewModel = ContentViewModel(locationManager: locationManagerMock, photosService: photosServiceMock)
    }

    func testStartUpdatingLocation() {
        viewModel.startUpdatingLocation()

        XCTAssertEqual(viewModel.state, .loading)
        XCTAssertFalse(viewModel.isPresentingError)
        XCTAssertTrue(viewModel.photosURL.isEmpty)
    }
    
    func testUpdateLocationManager_denied() {
        locationManagerMock.authorizationStatus = .denied
        
        viewModel.updateLocationManager()
        
        XCTAssertEqual(viewModel.state, .deniedLocation)
    }
    
    func testStopUpdatingLocation() {
        viewModel.stopUpdatingLocation()
        
        XCTAssertEqual(viewModel.state, .stopSharing)
    }
}

class FlickrServiceMock: PhotosServiceProtocol {
    func fetch<T>(_ type: T.Type, latitude: Double, longitude: Double) -> AnyPublisher<URL?, flickr_sample.APIError> where T : flickr_sample.PhotosResponse {
        
        let mockURL = URL(string: "https://flickr.com/image-url-example.jpg")
        return Just(mockURL)
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
}

class CLLocationManagerMock: CLLocationManagerProtocol {
    weak var delegate: CLLocationManagerDelegate?
    
    var distanceFilter: CLLocationDistance = 0
    var desiredAccuracy: CLLocationAccuracy = 0
    var pausesLocationUpdatesAutomatically: Bool = false
    var allowsBackgroundLocationUpdates: Bool = false
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    func requestAlwaysAuthorization() {}
    
    func requestWhenInUseAuthorization() {}
    
    func startUpdatingLocation() {}
    
    func stopUpdatingLocation() {}
}
