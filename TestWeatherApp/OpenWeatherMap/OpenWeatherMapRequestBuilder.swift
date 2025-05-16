//
//  OpenWeatherMapRequestBuilder.swift
//  TestWeatherApp
//
//  Created by user on 15.05.2025.
//

import Foundation
import Alamofire

let OPEN_WEATHERMAP_APPID = "63f90ae5889c24671a5dc80efa827738"

/// Построение запросов к api.openweathermap.org.
final class OpenWeatherMapRequestBuilder: WeatherAppRequestBuilderProtocol {
    private let baseRequest: URLRequest
    
    init(appid: String) {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")!
        components.queryItems = [.init(name: "appid", value: appid),
                                 .init(name: "units", value: "metric")]
        var baseRequest = URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        baseRequest.method = .get
        self.baseRequest = baseRequest
    }
    func weather(latitude: Double, longitude: Double, days: Int) throws(NSError) -> URLRequest {
        do {
            let latitude = latitude.format(precision: 2)
            let longitude = longitude.format(precision: 2)
            let parameters = ["lat": latitude, "lon": longitude]
            
            return try URLEncoding.queryString.encode(self.baseRequest, with: parameters)
        } catch let afError as AFError {
            throw NSError.initFrom(afError: afError)
        } catch {
            throw error as NSError
        }
    }
}
