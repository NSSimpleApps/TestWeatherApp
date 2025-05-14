//
//  WeatherAppModels.swift
//  TestWeatherApp
//
//  Created by user on 12.05.2025.
//

import Foundation

/// Протокол, который возвращает json-данные о погоде в зависимости от координат и дней.
protocol WeatherAppDataProviderProtocol: Sendable {
    func getWeatherData(latitude: Double, longitude: Double, days: Int) async throws(CancellationError) -> Result<Data, NSError>
}

/// Протокол, который парсит json-данные о погоде и возвращает предварительную модель.
protocol WeatherAppProviderProtocol: Sendable {
    func getWeather() async throws(CancellationError) -> Result<WeatherAppInfo, NSError>
}

/// Предварительная погодная модель.
/// Включает в себя погоду в данный момент,
/// погоду на ближайший день и прогноз на несколько дней вперёд.
struct WeatherAppInfo {
    let momentModel: WeatherAppMomentModel
    let dayModel: WeatherAppDayModel
    let forecastModel: WeatherAppForecastModel?
}

/// Погода в данный момент.
struct WeatherAppMomentModel {
    let location: String
    let locationName: String
    let temperature: String
    let weatherState: String
    let minMaxTemperature: String?
}
/// Погода на ближайший день.
struct WeatherAppDayModel {
    let title: String
    let hours: [WeatherAppDayHourModel]
}
/// Погода на ближайший день по часам.
struct WeatherAppDayHourModel {
    let time: String
    let temperature: String
    let weatherIcon: URL
}
/// Прогноз на несколько дней вперёд.
struct WeatherAppForecastModel {
    let title: String
    let days: [WeatherAppForecastDayModel]
}
/// Прогноз на несколько дней вперёд по дням.
struct WeatherAppForecastDayModel {
    let title: String
    let weatherIcon: URL
    let minTemperature: String
    let maxTemperature: String
}
