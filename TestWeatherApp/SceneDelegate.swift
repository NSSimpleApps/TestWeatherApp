//
//  SceneDelegate.swift
//  TestWeatherApp
//
//  Created by user on 12.05.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
//        Проверка данных от api.weatherapi.com.
        let weatherApiRequestBuilder = WeatherApiRequestBuilder(key: WEATHER_API_KEY)
        let weatherAppNetworkProvider = WeatherAppNetworkProvider(requestBuilder: weatherApiRequestBuilder)
        let weatherApiHandler = WeatherApiHandler(weatherApiProvider: weatherAppNetworkProvider)
        
//        Для проверки локальных данных от api.weatherapi.com.
//        let weatherApiTestProvider = WeatherApiTestProvider()
//        let weatherApiHandler = WeatherApiHandler(weatherApiProvider: weatherApiTestProvider)
        
        // Проверка данных от api.openweathermap.com.
//        let openWeatherMapRequestBuilder = OpenWeatherMapRequestBuilder(appid: OPEN_WEATHER_APPID)
//        let weatherAppNetworkProvider = WeatherAppNetworkProvider(requestBuilder: openWeatherMapRequestBuilder)
//        let openWeatherMapApiHandler = OpenWeatherMapApiHandler(weatherApiProvider: weatherAppNetworkProvider,
//                                                                screenScale: Int(windowScene.screen.scale))
        
//        Для проверки локальных данных от api.openweathermap.com.
//        let openWeatherMapTestProvider = OpenWeatherMapTestProvider()
//        let openWeatherMapApiHandler = OpenWeatherMapApiHandler(weatherApiProvider: openWeatherMapTestProvider)
        
        let weatherProvider: any WeatherAppProviderProtocol = weatherApiHandler
        
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        window.rootViewController = UINavigationController(rootViewController: WeatherAppViewController(weatherProvider: weatherProvider))
        self.window = window
        window.makeKeyAndVisible()
    }
}
