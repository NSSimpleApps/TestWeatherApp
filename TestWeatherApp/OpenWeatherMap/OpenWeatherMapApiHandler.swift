//
//  OpenWeatherMapApiHandler.swift
//  TestWeatherApp
//
//  Created by user on 15.05.2025.
//

import Foundation

/// Обработчик данных от api.openweathermap.org.
actor OpenWeatherMapApiHandler: WeatherAppProviderProtocol {
    private let weatherApiProvider: WeatherAppDataProviderProtocol
    private let locationManager = WeatherAppLocationManager()
    private let screenScale: Int
    
    init(weatherApiProvider: any WeatherAppDataProviderProtocol, screenScale: Int) {
        self.weatherApiProvider = weatherApiProvider
        self.screenScale = min(2, screenScale)
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
                let openWeatherMapData = try JSONDecoder().decode(OpenWeatherMapData.self, from: weatherData)
                let city = openWeatherMapData.city
                let list = openWeatherMapData.list
                
                let now = Date()
                var calendar = Calendar(identifier: .gregorian)
                if let timeZone = TimeZone(secondsFromGMT: city.timezone) {
                    calendar.timeZone = timeZone
                }
                let nowHour = calendar.component(.hour, from: now)
                let weatherApiDateParser = WeatherApiDateParser(calendar: calendar)
                
                var todayHourModels: [WeatherAppDayHourModel] = []
                var tomorrowHourModels: [WeatherAppDayHourModel] = []
                var forecastDayInfos: [Date: [OpenWeatherForecastDayInfo]] = [:]
                
                let shortWeekdaySymbols = calendar.standardizeWeekDaySymbols(symbols: { calendar in
                    calendar.shortWeekdaySymbols
                })
                
                var todayTemperatureValue: String?
                var todayWeatherStateValue: String?
                
                for weatherItem in list {
                    if let weatherDate = weatherApiDateParser.date(from: weatherItem.dt_txt) {
                        let weatherIcon: URL?
                        if let icon = weatherItem.weather.first?.icon {
                            weatherIcon = URL(string: "https://openweathermap.org/img/wn/\(icon)@\(self.screenScale)x.png")
                        } else {
                            weatherIcon = nil
                        }
                        
                        let weatherHour = calendar.component(.hour, from: weatherDate)
                        let temperature = weatherItem.main.temp.formattedTemperature
                        
                        if calendar.isDate(weatherDate, inSameDayAs: now) {
                            let time: String
                            if weatherHour == nowHour {
                                todayTemperatureValue = temperature
                                todayWeatherStateValue = weatherItem.weather.first?.main
                                time = "Now"
                            } else {
                                time = String(format: "%02d", weatherHour)
                            }
                            todayHourModels.append(.init(time: time, temperature: temperature,
                                                         weatherIcon: weatherIcon))
                            
                        } else {
                            let weatherDateStartOfDay = calendar.startOfDay(for: weatherDate)
                            if weatherDateStartOfDay.timeIntervalSince(calendar.startOfDay(for: now)) == 24 * 60 * 60 {
                                let time = String(format: "%02d", weatherHour)
                                tomorrowHourModels.append(.init(time: time, temperature: temperature,
                                                                weatherIcon: weatherIcon))
                            }
                            let shortWeekdaySymbol = shortWeekdaySymbols[calendar.weekDayIndex(date: weatherDate)]
                            
                            forecastDayInfos[weatherDateStartOfDay, default: []].append(.init(weekDayTitle: shortWeekdaySymbol,
                                                                                              minTemperature: weatherItem.main.temp_min,
                                                                                              maxTemperature: weatherItem.main.temp_max))
                        }
                    }
                }
                let forecastDays = forecastDayInfos.sorted { pair1, pair2 in
                    pair1.key < pair2.key
                }.compactMap { pair in
                    let array = pair.value
                    if let forecastDayInfo = array.first {
                        let minTemperature = array.map({ $0.minTemperature }).min()!
                        let maxTemperature = array.map({ $0.maxTemperature }).max()!
                        return WeatherAppForecastDayModel(title: forecastDayInfo.weekDayTitle, weatherIcon: nil,
                                                          minTemperature: minTemperature.formattedTemperature,
                                                          maxTemperature: maxTemperature.formattedTemperature,
                                                          humidity: "?", windSpeed: "?")
                    } else {
                        return nil
                    }
                }
                
                let todayTemperature: String
                if let todayTemperatureValue {
                    todayTemperature = todayTemperatureValue
                } else if let todayHourModel = todayHourModels.first {
                    todayTemperature = todayHourModel.temperature
                } else {
                    todayTemperature = "?"
                }
                
                let todayWeatherState: String
                if let todayWeatherStateValue {
                    todayWeatherState = todayWeatherStateValue
                } else {
                    todayWeatherState = list.first?.weather.first?.main ?? "?"
                }
                
                let momentModel =
                WeatherAppMomentModel(location: shouldUseDefaultLocation ? "DEFAULT LOCATION" : "MY LOCATION",
                                      locationName: city.name + ", " + city.country,
                                      temperature: todayTemperature,
                                      weatherState: todayWeatherState,
                                      minMaxTemperature: nil)
                
                let dayModel = WeatherAppDayModel(title: "TODAY FORECAST", hours: todayHourModels + tomorrowHourModels)
                
                let numberCase = forecastDays.count.numberCase(locale: "en")
                let formattedDays = numberCase.format(nominative: "DAY", genitive: "DAYS", plural: "DAYS")
                let forecastModel = WeatherAppForecastModel(title: String(forecastDays.count) + "-\(formattedDays) FORECAST", days: forecastDays)
                
                return .success(WeatherAppInfo(momentModel: momentModel, dayModel: dayModel, forecastModel: forecastModel))
            } catch {
                return .failure(error as NSError)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
/// Предварительная информация о будущих днях.
struct OpenWeatherForecastDayInfo {
    let weekDayTitle: String
    let minTemperature: Double
    let maxTemperature: Double
}
/// Модельные данные с api.openweathermap.org.
struct OpenWeatherMapData: Decodable {
    let city: OpenWeatherMapCity
    let list: [OpenWeatherMapList]
}
/// Информация о месте.
struct OpenWeatherMapCity: Decodable {
    let name: String
    let timezone: Int
    let country: String
}
/// Информация о погоде по временам.
struct OpenWeatherMapList: Decodable {
    let dt_txt: String
    let main: OpenWeatherMapListMain
    let weather: [OpenWeatherMapListWeather]
}
/// Информация о температуре в данное время.
struct OpenWeatherMapListMain: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
}
/// Информация о состоянии погоды в данное время.
struct OpenWeatherMapListWeather: Decodable {
    let main: String
    let icon: String
}
