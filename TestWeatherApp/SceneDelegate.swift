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
        
        let weatherApiRequestBuilder = WeatherApiRequestBuilder(key: WEATHER_API_KEY)
        let weatherApiProvider = WeatherApiProvider(requestBuilder: weatherApiRequestBuilder)
        let weatherApiHandler = WeatherApiHandler(weatherApiProvider: weatherApiProvider)
        
//        Для проверки.
//        let weatherAppTestProvider = WeatherAppTestProvider()
//        let weatherApiHandler = WeatherApiHandler(weatherApiProvider: weatherAppTestProvider)
        
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        window.rootViewController = UINavigationController(rootViewController: WeatherAppViewController(weatherProvider: weatherApiHandler))
        self.window = window
        window.makeKeyAndVisible()
    }
}
