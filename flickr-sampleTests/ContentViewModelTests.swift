//
//  ContentViewModelTests.swift
//  flickr-sampleTests
//
//  Created by Leo Quinteros on 7/08/23.
//

import XCTest
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
    }
    
    func testResumeUpdatingLocation() {
        viewModel.resumeUpdatingLocation()

        XCTAssertEqual(viewModel.state, .loaded([]))
    }
    
    func testUpdateLocationManagerDenied() {
        locationManagerMock.authorizationStatus = .denied
        
        viewModel.updateLocationManager()
        
        XCTAssertEqual(viewModel.state, .deniedLocation)
    }
    
    func testUpdateLocationManagerAuthorizedAlways() {
        locationManagerMock.authorizationStatus = .authorizedAlways
        
        viewModel.updateLocationManager()
        
        XCTAssertEqual(viewModel.state, .ready)
    }
    
    func testStopUpdatingLocation() {
        viewModel.stopUpdatingLocation()
        
        XCTAssertEqual(viewModel.state, .stopSharing)
    }
}

class FlickrServiceMock: PhotosServiceProtocol {
    func fetch<T>(_ type: T.Type, latitude: Double, longitude: Double) async -> Result<URL?, APIError> where T: PhotosResponse {
        
        let mockURL = URL(string: "https://flickr.com/image-url-example.jpg")
        return .success(mockURL)
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
