//
//  WeatherAppImageDownloader.swift
//  TestWeatherApp
//
//  Created by user on 14.05.2025.
//

import Foundation
import Alamofire
import AlamofireImage

/// Протокол для идентификации вьюшки по урлу изображения.
@MainActor @preconcurrency
protocol WeatherAppImageURLProtocol: AnyObject {
    var imageURL: URL? { get set }
}

/// Скачивание изображений по урлу.
@MainActor
final class WeatherAppImageDownloader {
    private let imageDownloader: ImageDownloader
    private let serializer = ImageResponseSerializer(imageScale: 1)
    
    init() {
        let imagesSessionConfiguration = URLSessionConfiguration.af.default
        imagesSessionConfiguration.urlCache = Self.createURLCache(path: "ns.simple.apps.images")
        
        let session = Session(configuration: imagesSessionConfiguration,
                              startRequestsImmediately: false)
        self.imageDownloader = ImageDownloader(session: session)
    }
    
    private static func createURLCache(path: String) -> URLCache {
        let memoryCapacity = 20 * 1024 * 1024
        let diskCapacity = 150 * 1024 * 1024
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity,
                                directory: cacheDirectory?.appendingPathComponent(path))
        return urlCache
    }
    
    func loadImage(imageURL: URL, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = imageURL.absoluteString
        self.imageDownloader.download(URLRequest(url: imageURL), cacheKey: cacheKey, receiptID: cacheKey,
                                      serializer: self.serializer, completion: { response in
            completion(response.value)
        })
    }
    func loadImageOn<ImageCell: WeatherAppImageURLProtocol>(cell: ImageCell, imageURL: URL,
                                                            completion: @escaping (ImageCell, UIImage) -> Void) {
        cell.imageURL = imageURL
        self.loadImage(imageURL: imageURL, completion: { [weak cell] image in
            guard let image, let cell, cell.imageURL == imageURL else { return }
            
            completion(cell, image)
        })
    }
}
