//
//  WeatherApiRequestBuilder.swift
//  TestWeatherApp
//
//  Created by user on 12.05.2025.
//

import Foundation
import Alamofire


let WEATHER_API_KEY = "fa8b3df74d4042b9aa7135114252304"

/// Построение запросов к api.weather.com.
final class WeatherApiRequestBuilder: Sendable {
    private let baseRequest: URLRequest
    
    init(key: String) {
        var components = URLComponents(string: "http://api.weatherapi.com/v1/forecast.json")!
        components.queryItems = [.init(name: "key", value: key)]
        var baseRequest = URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        baseRequest.method = .get
        self.baseRequest = baseRequest
    }
    
    func weather(latitude: Double, longitude: Double, days: Int) throws(NSError) -> URLRequest {
        do {
            let latitude = latitude.format(precision: 2)
            let longitude = longitude.format(precision: 2)
            var parameters = ["q": latitude + "," + longitude]
            if days > 0 {
                parameters["days"] = String(days)
            }
            return try URLEncoding.queryString.encode(self.baseRequest, with: parameters)
        } catch let afError as AFError {
            throw NSError.initFrom(afError: afError)
        } catch {
            throw error as NSError
        }
    }
}
