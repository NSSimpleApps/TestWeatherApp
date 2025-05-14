//
//  WeatherAppTestProvider.swift
//  TestWeatherApp
//
//  Created by user on 14.05.2025.
//

import Foundation

/// Проверочный класс для передачи данных о погоде в сохранённом json.
actor WeatherAppTestProvider: WeatherAppDataProviderProtocol {
    func getWeatherData(latitude: Double, longitude: Double, days: Int) async throws(CancellationError) -> Result<Data, NSError> {
        if let url = Bundle.main.url(forResource: "test_weather", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return .success(data)
            } catch {
                return .failure(error as NSError)
            }
        } else {
            return .failure(NSError(code: -1, reason: "Local weather json not found."))
        }
    }
}
