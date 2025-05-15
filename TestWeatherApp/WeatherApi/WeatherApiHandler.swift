//
//  WeatherApiHandler.swift
//  TestWeatherApp
//
//  Created by user on 13.05.2025.
//

import Foundation

/// Обработчик данных от api.weather.com.
actor WeatherApiHandler: WeatherAppProviderProtocol {
    private let weatherApiProvider: WeatherAppDataProviderProtocol
    private let locationManager = WeatherAppLocationManager()
    
    init(weatherApiProvider: WeatherAppDataProviderProtocol) {
        self.weatherApiProvider = weatherApiProvider
    }
    
    func getWeather() async throws(CancellationError) -> Result<WeatherAppInfo, NSError> {
        let coordinates = await withCheckedContinuation { continuation in
            var anyCancellable: Any?
            anyCancellable = self.locationManager.requestWhenInUseAuthorization(completion: { coordinates in
                continuation.resume(returning: coordinates)
                if let anyCancellable {
                    print(anyCancellable)
                }
            })
        }
        let latitude = coordinates?.latitude ?? 55.4
        let longitude = coordinates?.longitude ?? 37.3
        let shouldUseDefaultLocation = coordinates == nil
        let weatherDataResult = try await self.weatherApiProvider.getWeatherData(latitude: latitude, longitude: longitude, days: 7)
        
        switch weatherDataResult {
        case .success(let weatherData):
            do {
                let weatherApiData = try JSONDecoder().decode(WeatherApiData.self, from: weatherData)
                let location = weatherApiData.location
                let current = weatherApiData.current
                let forecastday = weatherApiData.forecast.forecastday
                
                let now = Date()
                var calendar = Calendar(identifier: .gregorian)
                if let timeZone = TimeZone(identifier: location.timeZone) {
                    calendar.timeZone = timeZone
                }
                let weatherApiDateParser = WeatherApiDateParser(calendar: calendar)
                
                let minMaxTemperature: String?
                let todayHourModels: [WeatherAppDayHourModel]
                let tomorrowHourModels: [WeatherAppDayHourModel]
                
                if let todayForecast = forecastday.first {
                    let minTemperature = todayForecast.minTemperature
                    let maxTemperature = todayForecast.maxTemperature
                    minMaxTemperature = "min: \(self.formatted(temperature: minTemperature)), max: \(self.formatted(temperature: maxTemperature))"
                    
                    let nowHour = calendar.component(.hour, from: now)
                    
                    todayHourModels = todayForecast.hours.compactMap { forecastDayHour in
                        if let hourDate = weatherApiDateParser.date(from: forecastDayHour.time),
                           var components = URLComponents(string: forecastDayHour.icon) {
                            let hour = calendar.component(.hour, from: hourDate)
                            if hour >= nowHour {
                                let time: String
                                if hour == nowHour {
                                    time = "Now"
                                } else {
                                    time = String(format: "%02d", hour)
                                }
                                components.scheme = "http"
                                return WeatherAppDayHourModel(time: time,
                                                              temperature: self.formatted(temperature: forecastDayHour.temperature),
                                                              weatherIcon: components.url!)
                            } else {
                                return nil
                            }
                        } else {
                            return nil
                        }
                    }
                    
                    if let tomorrowForecast = forecastday.dropFirst().first {
                        tomorrowHourModels = tomorrowForecast.hours.compactMap { forecastDayHour in
                            if let hourDate = weatherApiDateParser.date(from: forecastDayHour.time),
                               var components = URLComponents(string: forecastDayHour.icon) {
                                let hour = calendar.component(.hour, from: hourDate)
                                components.scheme = "http"
                                return WeatherAppDayHourModel(time: String(format: "%02d", hour),
                                                              temperature: self.formatted(temperature: forecastDayHour.temperature),
                                                              weatherIcon: components.url!)
                            } else {
                                return nil
                            }
                        }
                    } else {
                        tomorrowHourModels = []
                    }
                } else {
                    minMaxTemperature = nil
                    todayHourModels = []
                    tomorrowHourModels = []
                }
                
                
                let temperature = self.formatted(temperature: current.temperature)
                let weatherState = current.condition.text
                let locationName = location.name + ", " + location.country
                let momentModel =
                WeatherAppMomentModel(location: shouldUseDefaultLocation ? "DEFAULT LOCATION" : "MY LOCATION",
                                      locationName: locationName,
                                      temperature: temperature,
                                      weatherState: weatherState,
                                      minMaxTemperature: minMaxTemperature)
                
                let dayModel =
                WeatherAppDayModel(title: "TODAY FORECAST", hours: todayHourModels + tomorrowHourModels)
                
                let forecastModel: WeatherAppForecastModel?
                if forecastday.isEmpty {
                    forecastModel = nil
                } else {
                    let shortWeekdaySymbols = calendar.shortWeekdaySymbols
                    let days = forecastday.compactMap { forecastDay in
                        if let dayDate = weatherApiDateParser.date(from: forecastDay.date),
                           var components = URLComponents(string: forecastDay.icon) {
                            let title: String
                            if calendar.isDate(now, inSameDayAs: dayDate) {
                                title = "Today"
                            } else {
                                title = shortWeekdaySymbols[calendar.component(.weekday, from: dayDate) - 1]
                            }
                            components.scheme = "http"
                            return WeatherAppForecastDayModel(title: title, weatherIcon: components.url!,
                                                              minTemperature: self.formatted(temperature: forecastDay.minTemperature),
                                                              maxTemperature: self.formatted(temperature: forecastDay.maxTemperature))
                        } else {
                            return nil
                        }
                    }
                    let numberCase = forecastday.count.numberCase(locale: "en")
                    let formattedDays = numberCase.format(nominative: "DAY", genitive: "DAYS", plural: "DAYS")
                    forecastModel = WeatherAppForecastModel(title: String(forecastday.count) + "-\(formattedDays) FORECAST", days: days)
                }
                
                return .success(WeatherAppInfo(momentModel: momentModel, dayModel: dayModel, forecastModel: forecastModel))
            } catch {
                return .failure(error as NSError)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func formatted(temperature: Double) -> String {
        return temperature.format(precision: 1) + "°"
    }
}
/// Модельные данные от api.weather.com.
/// Включает в себя местоположение, текущее состояние погоды и прогноз.
struct WeatherApiData: Decodable {
    let location: WeatherApiLocation
    let current: WeatherApiCurrent
    let forecast: WeatherApiForecast
    
    enum CodingKeys: CodingKey {
        case location
        case current
        case forecast
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.location = try container.decode(WeatherApiLocation.self, forKey: .location)
        self.current = try container.decode(WeatherApiCurrent.self, forKey: .current)
        self.forecast = try container.decode(WeatherApiForecast.self, forKey: .forecast)
    }
}
/// Модельные данные от api.weather.com.
/// Местоположение.
struct WeatherApiLocation: Decodable {
    let name: String
    let country: String
    let timeZone: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case country
        case timeZone = "tz_id"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.country = try container.decode(String.self, forKey: .country)
        self.timeZone = try container.decode(String.self, forKey: .timeZone)
    }
}
/// Модельные данные от api.weather.com.
/// Текущее состояние погоды.
struct WeatherApiCurrent: Decodable {
    let temperature: Double
    let condition: WeatherApiCondition
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp_c"
        case condition
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.temperature = try container.decode(Double.self, forKey: .temperature)
        self.condition = try container.decode(WeatherApiCondition.self, forKey: .condition)
    }
}
/// Модельные данные от api.weather.com.
/// Текущее состояние погоды.
struct WeatherApiCondition: Decodable {
    let text: String
    let icon: String
}
/// Модельные данные от api.weather.com.
/// Прогноз погоды на несколько дней.
struct WeatherApiForecast: Decodable {
    let forecastday: [WeatherApiForecastDay]
}
/// Модельные данные от api.weather.com.
/// Прогноз погоды по дням.
struct WeatherApiForecastDay: Decodable {
    let date: String
    let minTemperature: Double
    let maxTemperature: Double
    let icon: String
    let hours: [WeatherApiForecastDayHour]
    
    enum CodingKeys: String, CodingKey {
        case date
        case day
        case condition
        case minTemperature = "mintemp_c"
        case maxTemperature = "maxtemp_c"
        case hours = "hour"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dayContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .day)
        
        self.date = try container.decode(String.self, forKey: .date)
        self.minTemperature = try dayContainer.decode(Double.self, forKey: .minTemperature)
        self.maxTemperature = try dayContainer.decode(Double.self, forKey: .maxTemperature)
        self.icon = try dayContainer.decode(WeatherApiCondition.self, forKey: .condition).icon
        self.hours = try container.decode([WeatherApiForecastDayHour].self, forKey: .hours)
    }
}
/// Модельные данные от api.weather.com.
/// Прогноз погоды по часам.
struct WeatherApiForecastDayHour: Decodable {
    let time: String
    let temperature: Double
    let icon: String
    
    enum CodingKeys: CodingKey {
        case time
        case condition
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.time = try container.decode(String.self, forKey: .time)
        self.temperature = try WeatherApiTemperature(from: decoder).temperature
        self.icon = try container.decode(WeatherApiCondition.self, forKey: .condition).icon
    }
}
/// Модельные данные от api.weather.com.
/// Температура.
struct WeatherApiTemperature: Decodable {
    enum CodingKeys: String, CodingKey {
        case temperature = "temp_c"
    }
    
    let temperature: Double
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.temperature = try container.decode(Double.self, forKey: .temperature)
    }
}
