//
//  WeatherAppNetworkProvider.swift
//  TestWeatherApp
//
//  Created by user on 15.05.2025.
//

import Foundation
import Alamofire

/// Протокол для построения запросов к серверу.
protocol WeatherAppRequestBuilderProtocol: Sendable {
    func weather(latitude: Double, longitude: Double, days: Int) throws(NSError) -> URLRequest
}

/// Скачивание данных с сети в зависимости от запросов.
actor WeatherAppNetworkProvider: WeatherAppDataProviderProtocol {
    private let requestBuilder: WeatherAppRequestBuilderProtocol
    private let session: Session
    
    init(requestBuilder: any WeatherAppRequestBuilderProtocol) {
        self.requestBuilder = requestBuilder
        self.session = Session(startRequestsImmediately: false)
    }
    
    func getWeatherData(latitude: Double, longitude: Double, days: Int) async throws(CancellationError) -> Result<Data, NSError> {
        let weatherRequest: URLRequest
        do {
            weatherRequest = try self.requestBuilder.weather(latitude: latitude, longitude: longitude, days: days)
        } catch {
            return .failure(error)
        }
        let sessionRequest = self.session.request(weatherRequest)
            .validate()
        let dataTask = sessionRequest.serializingData()
        sessionRequest.resume()
        let response = await dataTask.response
        try Task.checkIfCancelled()
        
        if let afError = response.error {
            let nsError = NSError.initFrom(afError: afError)
            if nsError.isCancelled {
                throw CancellationError()
            } else {
                return .failure(nsError)
            }
        } else if let httpResponse = response.response {
            let statusCode = httpResponse.statusCode
            if statusCode >= 200 && statusCode < 300 {
                if let data = response.data {
                    return .success(data)
                } else {
                    let nsError = NSError(code: statusCode, reason: "Empty response.")
                    return .failure(nsError)
                }
            } else {
                let nsError = NSError(code: statusCode, reason: "Invalid status code.")
                return .failure(nsError)
            }
        } else {
            let nsError = NSError(code: -1, reason: "There is not appropriate info.")
            return .failure(nsError)
        }
    }
}


