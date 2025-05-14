//
//  WeatherAppLocationManager.swift
//  TestWeatherApp
//
//  Created by user on 13.05.2025.
//


import Foundation
import CoreLocation
import Combine

/// Координаты места.
struct WeatherAppCoordinates: Sendable {
    let latitude: Double
    let longitude: Double
    
    init?(locationCoordinate2D: CLLocationCoordinate2D?) {
        if let locationCoordinate2D {
            self.latitude = locationCoordinate2D.latitude
            self.longitude = locationCoordinate2D.longitude
        } else {
            return nil
        }
    }
}

/// Получение координат места.
final class WeatherAppLocationManager: NSObject {
    private let locationManager = CLLocationManager()
    private let locationPublisher = PassthroughSubject<CLLocationCoordinate2D?, Never>()
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
    }
    
    func requestWhenInUseAuthorization(completion: @escaping (WeatherAppCoordinates?) -> Void) -> AnyCancellable? {
        if self.locationManager.authorizationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
            return self.locationPublisher.sink(receiveValue: { locationCoordinate2D in
                completion(.init(locationCoordinate2D: locationCoordinate2D))
            })
        } else {
            let location = self.locationManager.location?.coordinate
            completion(.init(locationCoordinate2D: location))
            return nil
        }
    }
}
extension WeatherAppLocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .notDetermined {
            let location = manager.location?.coordinate
            self.locationPublisher.send(location)
        }
    }
}
