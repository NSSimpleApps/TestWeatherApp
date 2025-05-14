//
//  WeatherAppViewController.swift
//  TestWeatherApp
//
//  Created by user on 12.05.2025.
//

import UIKit


/// Экран для отображения погоды.
final class WeatherAppViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let weatherProvider: WeatherAppProviderProtocol
    private let imageDownloader = WeatherAppImageDownloader()
    private var sections: [WeatherAppSection] = []
    
    init(weatherProvider: any WeatherAppProviderProtocol) {
        self.weatherProvider = weatherProvider
        let collectionViewFlowLayout = WeatherAppCollectionViewFlowLayout(shouldDisplayBorder: { collectionView, section in
            guard let self = collectionView.parentViewController(ofType: Self.self) else { return false }
            
            switch self.sections[section] {
            case .moment:
                return false
            case .day:
                return true
            case .forecast:
                return true
            }
        })
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        super.init(collectionViewLayout: collectionViewFlowLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: CGFloat(144) / 255, green: CGFloat(213) / 255, blue: 1, alpha: 1)
        
        let collectionView = self.collectionView!
        collectionView.preservesSuperviewLayoutMargins = true
        collectionView.backgroundColor = nil
        collectionView.register(cellClass: WeatherAppMomentCell.self)
        collectionView.register(cellClass: WeatherAppMomentMinMaxTemperatureCell.self)
        collectionView.registerHeader(headerClass: WeatherAppDayHeader.self)
        collectionView.register(cellClass: WeatherAppDayCell.self)
        collectionView.register(cellClass: WeatherAppForecastDayCell.self)
        collectionView.registerHeader(headerClass: UICollectionReusableView.self)
        collectionView.registerFooter(footerClass: UICollectionReusableView.self)
        
        let refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { action in
            guard let refreshControl = action.sender as? UIRefreshControl else { return }
            guard let `self` = refreshControl.parentViewController(ofType: Self.self) else { return }
            
            self.loadWeather()
        }))
        refreshControl.tintColor = .white
        collectionView.refreshControl = refreshControl
        
        self.loadWeather()
    }
    
    private func loadWeather() {
        let weatherProvider = self.weatherProvider
        Task { [weak self] in
            let weatherAppInfoResult = try await weatherProvider.getWeather()
            guard let self else { return }
            
            self.collectionView.refreshControl?.endRefreshing()
            
            switch weatherAppInfoResult {
            case .success(let weatherAppInfo):
                self.display(weatherAppInfo: weatherAppInfo)
            case .failure(let error):
                print(error)
                
                let alertController =
                UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alertController.addAction(UIAlertAction(title: "Retry", style: .default,
                                                        handler: { [weak self] _ in
                    guard let self else { return }
                    
                    self.loadWeather()
                }))
                self.present(alertController, animated: true)
            }
        }
    }
    
    func display(weatherAppInfo: WeatherAppInfo) {
        var sections: [WeatherAppSection] = [.moment(weatherAppInfo.momentModel),
                                             .day(.init(dayModel: weatherAppInfo.dayModel, imageDownloader: self.imageDownloader))]
        if let forecastModel = weatherAppInfo.forecastModel {
            sections.append(.forecast(forecastModel))
        }
        self.sections = sections
        self.collectionView.reloadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = self.sections.count
        if count == 0 {
            if (collectionView.backgroundView is UIActivityIndicatorView) == false {
                let activityIndicatorView = UIActivityIndicatorView(style: .medium)
                activityIndicatorView.color = .white
                activityIndicatorView.startAnimating()
                collectionView.backgroundView = activityIndicatorView
            }
        } else {
            collectionView.backgroundView = nil
        }
        
        return count
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.sections[section] {
        case .moment:
            return 1
        case .day:
            return 1
        case .forecast(let forecastModel):
            return forecastModel.days.count
        }
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.sections[indexPath.section] {
        case .moment(let momentModel):
            return self.createMomentCell(momentModel: momentModel, collectionView: collectionView, shouldDeque: true, indexPath: indexPath)
            
        case .day(let dayHandler):
            let dayCell = collectionView.dequeueReusableCell(withCellClass: WeatherAppDayCell.self, for: indexPath)
            let collectionView = dayCell.collectionView
            collectionView.dataSource = dayHandler
            collectionView.delegate = dayHandler
            
            UIView.performWithoutAnimation {
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
            }
            return dayCell
            
        case .forecast(let forecastModel):
            let item = indexPath.item
            let day = forecastModel.days[item]
            let forecastDayCell = collectionView.dequeueReusableCell(withCellClass: WeatherAppForecastDayCell.self, for: indexPath)
            forecastDayCell.separator.isHidden = forecastModel.days.count - 1 == item
            forecastDayCell.titleLabel.text = day.title
            
            forecastDayCell.weatherImageView.image = nil
            self.imageDownloader.loadImageOn(cell: forecastDayCell, imageURL: day.weatherIcon,
                                             completion: { forecastDayCell, image in
                forecastDayCell.weatherImageView.image = image
            })
            
            forecastDayCell.minTemperatureLabel.text = day.minTemperature
            forecastDayCell.maxTemperatureLabel.text = day.maxTemperature
            return forecastDayCell
        }
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            return collectionView.dequeueFooter(footerClass: UICollectionReusableView.self, for: indexPath)
        } else {
            switch self.sections[indexPath.section] {
            case .moment:
                return collectionView.dequeueHeader(headerClass: UICollectionReusableView.self, for: indexPath)
            case .day(let dayHandler):
                let dayHeader = collectionView.dequeueHeader(headerClass: WeatherAppDayHeader.self, for: indexPath)
                self.configure(dayHeader: dayHeader, dayModel: dayHandler.dayModel)
                return dayHeader
            case .forecast(let forecastModel):
                let dayHeader = collectionView.dequeueHeader(headerClass: WeatherAppDayHeader.self, for: indexPath)
                dayHeader.weatherStateLabel.text = forecastModel.title
                return dayHeader
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.readableContentGuide.layoutFrame.width
        let layoutSize = CGSize(width: width, height: collectionView.frame.height)
        let height: CGFloat
        
        switch self.sections[indexPath.section] {
        case .moment(let momentModel):
            let momentCell = self.createMomentCell(momentModel: momentModel, collectionView: collectionView, shouldDeque: false, indexPath: indexPath)
            height = momentCell.autoLayoutHeight(parentSize: layoutSize)
        case .day:
            height = 100
        case .forecast:
            height = 44
        }
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.readableContentGuide.layoutFrame.width
        let layoutSize = CGSize(width: width, height: collectionView.frame.height)
        let height: CGFloat
        
        switch self.sections[section] {
        case .moment:
            height = 0
        case .day(let dayHandler):
            let dayHeader = WeatherAppDayHeader(frame: CGRect(origin: .zero, size: layoutSize))
            self.configure(dayHeader: dayHeader, dayModel: dayHandler.dayModel)
            height = dayHeader.autoLayoutHeight(parentSize: layoutSize)
        case .forecast:
            height = 30
        }
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let height: CGFloat
        
        switch self.sections[section] {
        case .moment:
            height = 30
        case .day:
            height = 30
        case .forecast:
            height = 0
        }
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    private func createMomentCell(momentModel: WeatherAppMomentModel, collectionView: UICollectionView, shouldDeque: Bool, indexPath: IndexPath) -> WeatherAppMomentCell {
        let minMaxTemperature = momentModel.minMaxTemperature
        let momentCell: WeatherAppMomentCell
        if shouldDeque {
            if minMaxTemperature == nil {
                momentCell = collectionView.dequeueReusableCell(withCellClass: WeatherAppMomentCell.self, for: indexPath)
            } else {
                momentCell = collectionView.dequeueReusableCell(withCellClass: WeatherAppMomentMinMaxTemperatureCell.self, for: indexPath)
            }
        } else {
            let layoutFrame = collectionView.readableContentGuide.layoutFrame
            if minMaxTemperature == nil {
                momentCell = WeatherAppMomentCell(frame: layoutFrame)
            } else {
                momentCell = WeatherAppMomentMinMaxTemperatureCell(frame: layoutFrame)
            }
            momentCell.layoutMargins = collectionView.layoutMargins
        }
        momentCell.locationLabel.text = momentModel.location
        momentCell.locationNameLabel.text = momentModel.locationName
        momentCell.temperatureLabel.text = momentModel.temperature
        momentCell.weatherStateLabel.text = momentModel.weatherState
        
        if let minMaxTemperature = momentModel.minMaxTemperature,
           let momentMinMaxTemperatureProtocol = momentCell as? WeatherAppMomentMinMaxTemperatureProtocol {
            momentMinMaxTemperatureProtocol.minMaxTemperatureLabel.text = minMaxTemperature
        }
        return momentCell
    }
    private func configure(dayHeader: WeatherAppDayHeader, dayModel: WeatherAppDayModel) {
        dayHeader.weatherStateLabel.text = dayModel.title
    }
}
/// Секции для отображения погоды. См. `WeatherAppInfo`.
enum WeatherAppSection {
    case moment(WeatherAppMomentModel)
    case day(WeatherAppDayHandler)
    case forecast(WeatherAppForecastModel)
}
