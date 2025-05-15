//
//  WeatherApiTestProvider.swift
//  TestWeatherApp
//
//  Created by user on 14.05.2025.
//

import Foundation

/// Проверочный класс для передачи данных о погоде в сохранённом json от api.weather.com.
actor WeatherApiTestProvider: WeatherAppDataProviderProtocol {
    func getWeatherData(latitude: Double, longitude: Double, days: Int) async throws(CancellationError) -> Result<Data, NSError> {
        let fileName = "test_weatherapi"
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return .success(data)
            } catch {
                return .failure(error as NSError)
            }
        } else {
            return .failure(NSError(code: -1, reason: "\(fileName).json not found."))
        }
    }
}
