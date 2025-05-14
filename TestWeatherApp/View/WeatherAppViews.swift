//
//  WeatherAppViews.swift
//  TestWeatherApp
//
//  Created by user on 12.05.2025.
//


import UIKit


/// Погода на данный момент.
class WeatherAppMomentCell: UICollectionViewCell {
    let locationLabel = UILabel()
    let locationNameLabel = UILabel()
    let temperatureLabel = UILabel()
    let weatherStateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = nil
        let contentView = self.contentView
        contentView.backgroundColor = nil
        
        let textColor = UIColor.white
        
        self.locationLabel.textColor = textColor
        self.locationLabel.textAlignment = .center
        contentView.autoLayoutSubview(self.locationLabel)
        self.locationLabel.topEquals(to: contentView)
        self.locationLabel.leftRightEqualsToLayoutMargin(of: contentView)
        
        self.locationNameLabel.textColor = textColor
        self.locationNameLabel.textAlignment = .center
        contentView.autoLayoutSubview(self.locationNameLabel)
        self.locationNameLabel.topEqualsToBorder(of: self.locationLabel.bottomAnchor, space: 8)
        self.locationNameLabel.leftRightEquals(to: self.locationLabel)
        
        self.temperatureLabel.font = UIFont.systemFont(ofSize: 42, weight: .semibold)
        self.temperatureLabel.textColor = textColor
        self.temperatureLabel.textAlignment = .center
        contentView.autoLayoutSubview(self.temperatureLabel)
        self.temperatureLabel.topEqualsToBorder(of: self.locationNameLabel.bottomAnchor, space: 8)
        self.temperatureLabel.leftRightEquals(to: self.locationNameLabel)
        
        self.weatherStateLabel.textColor = textColor
        self.weatherStateLabel.textAlignment = .center
        contentView.autoLayoutSubview(self.weatherStateLabel)
        self.weatherStateLabel.topEqualsToBorder(of: self.temperatureLabel.bottomAnchor, space: 8)
        self.weatherStateLabel.leftRightEquals(to: self.temperatureLabel)
        
        if let momentMinMaxTemperatureCell = self as? WeatherAppMomentMinMaxTemperatureProtocol {
            let minMaxTemperatureLabel = momentMinMaxTemperatureCell.minMaxTemperatureLabel
            minMaxTemperatureLabel.textColor = textColor
            minMaxTemperatureLabel.textAlignment = .center
            contentView.autoLayoutSubview(minMaxTemperatureLabel)
            minMaxTemperatureLabel.topEqualsToBorder(of: self.weatherStateLabel.bottomAnchor, space: 8)
            minMaxTemperatureLabel.leftRightEquals(to: self.weatherStateLabel)
            minMaxTemperatureLabel.bottomEquals(to: contentView)
        } else {
            self.weatherStateLabel.bottomEquals(to: contentView)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
/// Протокол для ячейки, которая отображает вдобавок минимальную и максимальную температуру.
protocol WeatherAppMomentMinMaxTemperatureProtocol: WeatherAppMomentCell {
    var minMaxTemperatureLabel: UILabel { get }
}
/// Ячейки, которая отображает вдобавок минимальную и максимальную температуру.
final class WeatherAppMomentMinMaxTemperatureCell: WeatherAppMomentCell, WeatherAppMomentMinMaxTemperatureProtocol {
    let minMaxTemperatureLabel = UILabel()
}

/// Заголовок для секции о погоде на ближайший день или несколько дней вперёд.
final class WeatherAppDayHeader: UICollectionReusableView {
    let weatherStateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.preservesSuperviewLayoutMargins = true
        self.backgroundColor = nil
        
        self.weatherStateLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        self.weatherStateLabel.textColor = .white.withAlphaComponent(0.8)
        self.autoLayoutSubview(self.weatherStateLabel)
        self.weatherStateLabel.topBottomEquals(to: self, inset: 8)
        self.weatherStateLabel.leftRightEqualsToReadableMargin(of: self, inset: 8)
        
        let separator = UIView()
        separator.backgroundColor = .white
        self.autoLayoutSubview(separator)
        separator.heightEqualsTo(CGFloat.separatorSize)
        separator.leftRightEquals(to: self.weatherStateLabel)
        separator.bottomEquals(to: self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
/// Ячейка о погоде на несколько дней вперёд.
final class WeatherAppDayCell: UICollectionViewCell {
    let collectionView: UICollectionView
    
    override init(frame: CGRect) {
        let сollectionViewFlowLayout = UICollectionViewFlowLayout()
        сollectionViewFlowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: сollectionViewFlowLayout)
        collectionView.backgroundColor = nil
        collectionView.register(cellClass: WeatherAppDayHourCell.self)
        collectionView.preservesSuperviewLayoutMargins = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        self.collectionView = collectionView
        super.init(frame: frame)
        
        self.backgroundColor = nil
        let contentView = self.contentView
        contentView.backgroundColor = nil
        contentView.autoLayoutSubview(collectionView)
        collectionView.topBottomEquals(to: contentView)
        collectionView.leftRightEquals(to: contentView)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
/// Погода по часам на ближайший день.
final class WeatherAppDayHourCell: UICollectionViewCell, WeatherAppImageURLProtocol {
    let topLabel = UILabel()
    let weatherImageView = UIImageView()
    let bottomLabel = UILabel()
    
    var imageURL: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = nil
        let contentView = self.contentView
        contentView.backgroundColor = nil
        
        self.topLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        self.topLabel.textColor = .white
        self.topLabel.textAlignment = .center
        contentView.autoLayoutSubview(self.topLabel)
        self.topLabel.topEquals(to: contentView, inset: 12)
        self.topLabel.leftRightEquals(to: contentView)
        
        contentView.autoLayoutSubview(self.weatherImageView)
        self.weatherImageView.centerEquals(to: contentView)
        self.weatherImageView.sizeEqualsTo(square: 24)
        
        self.bottomLabel.font = self.topLabel.font
        self.bottomLabel.textColor = .white
        self.bottomLabel.textAlignment = .center
        contentView.autoLayoutSubview(self.bottomLabel)
        self.bottomLabel.bottomEquals(to: contentView, inset: 12)
        self.bottomLabel.leftRightEquals(to: contentView)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Прогноз на будущие дни.
final class WeatherAppForecastDayCell: UICollectionViewCell, WeatherAppImageURLProtocol {
    let titleLabel = UILabel()
    let weatherImageView = UIImageView()
    let minTemperatureLabel = UILabel()
    let maxTemperatureLabel = UILabel()
    let separator = UIView()
    
    var imageURL: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = nil
        let contentView = self.contentView
        contentView.backgroundColor = nil
        
        let textColor = UIColor.white
        
        self.titleLabel.textColor = textColor
        contentView.autoLayoutSubview(self.titleLabel)
        self.titleLabel.leftEqualsToLayoutMargin(of: contentView)
        self.titleLabel.centerYEquals(to: contentView)
        
        contentView.autoLayoutSubview(self.weatherImageView)
        self.weatherImageView.sizeEqualsTo(square: 24)
        self.weatherImageView.centerEquals(to: contentView)
        
        self.maxTemperatureLabel.textAlignment = .right
        self.maxTemperatureLabel.textColor = textColor
        contentView.autoLayoutSubview(self.maxTemperatureLabel)
        self.maxTemperatureLabel.centerYEquals(to: contentView)
        self.maxTemperatureLabel.rightEqualsToLayoutMargin(of: contentView)
        self.maxTemperatureLabel.widthEqualsTo(50)
        
        self.minTemperatureLabel.textAlignment = .center
        self.minTemperatureLabel.textColor = textColor
        contentView.autoLayoutSubview(self.minTemperatureLabel)
        self.minTemperatureLabel.centerYEquals(to: contentView)
        self.minTemperatureLabel.rightEqualsToBorder(of: self.maxTemperatureLabel.leftAnchor, space: 16)
        self.minTemperatureLabel.widthEqualsTo(50)
        
        self.separator.backgroundColor = .white
        contentView.autoLayoutSubview(self.separator)
        self.separator.heightEqualsTo(CGFloat.separatorSize)
        self.separator.leftEquals(to: self.titleLabel)
        self.separator.rightEquals(to: self.maxTemperatureLabel)
        self.separator.bottomEquals(to: contentView)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
