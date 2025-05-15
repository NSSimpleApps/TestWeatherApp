//
//  WeatherAppDayHandler.swift
//  TestWeatherApp
//
//  Created by user on 14.05.2025.
//

import UIKit

/// Управление ячейками с почасовым прогнозом погоды.
final class WeatherAppDayHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let dayModel: WeatherAppDayModel
    let imageDownloader: WeatherAppImageDownloader
    
    init(dayModel: WeatherAppDayModel, imageDownloader: WeatherAppImageDownloader) {
        self.dayModel = dayModel
        self.imageDownloader = imageDownloader
        
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dayModel.hours.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hour = self.dayModel.hours[indexPath.item]
        let dayHourCell = collectionView.dequeueReusableCell(withCellClass: WeatherAppDayHourCell.self, for: indexPath)
        dayHourCell.topLabel.text = hour.time
        
        dayHourCell.weatherImageView.image = nil
        if let weatherIcon = hour.weatherIcon {
            self.imageDownloader.loadImageOn(cell: dayHourCell, imageURL: weatherIcon,
                                             completion: { dayHourCell, image in
                dayHourCell.weatherImageView.image = image
            })
        }
        dayHourCell.bottomLabel.text = hour.temperature
        return dayHourCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: collectionView.frame.height)
    }
}
