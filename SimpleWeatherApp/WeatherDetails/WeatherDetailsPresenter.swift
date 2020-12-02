//
//  WeatherDetailsPresenter.swift
//  SimpleWeatherApp
//
//  Created by Александр Камышев on 18.11.2020.
//

import Foundation
import Domain

class WeatherDetailsPresenter: WeatherDetailsPresenterProtocol {
    private let useCase: WeatherDataUseCase
    private var weatherData: WeatherData
    unowned private let delegate: WeatherDetailsViewDelegate
    unowned private let view: WeatherDetailsView
    
    private var weatherDescription: String {
        "Temp: \(weatherData.main.temp) °C\nMax temp: \(weatherData.main.tempMax) °C\nMin temp: \(weatherData.main.tempMin) °C\nDatetime: \(Date(timeIntervalSince1970: TimeInterval(weatherData.dt)))"
    }
    
    private var navigationItemTitle: String {
        "Weather in \(weatherData.name)"
    }
    
    init(view: WeatherDetailsView, useCase: WeatherDataUseCase, weatherData: WeatherData, delegate: WeatherDetailsViewDelegate) {
        self.view = view
        self.useCase = useCase
        self.weatherData = weatherData
        self.delegate = delegate
    }
    
    func viewDidLoad() {
        view.setCityName(weatherData.name)
        view.setFavoriteButtonImage(Images.getStarImageFor(value: weatherData.isFavorited))
        view.setNavigationItemTitle(navigationItemTitle)
        view.setWeatherDescription(weatherDescription)
    }
    
    func updateFavoriteValue() {
        let newValue = !weatherData.isFavorited
        useCase.setFavorited(value: newValue, for: weatherData) { [weak self] (result) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(_):
                self.view.setFavoriteButtonImage(Images.getStarImageFor(value: newValue))
                self.weatherData.isFavorited = newValue
                self.delegate.weatherDataWasSetFavorited(value: newValue, id: self.weatherData.id)
            case .failure(let error):
                self.view.showError(error)
            }
        }
    }
    
}
