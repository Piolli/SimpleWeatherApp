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
    unowned private let view: WeatherDetailsViewDelegate
    
    private var weatherDescription: String {
        "Temp: \(weatherData.main.temp) °C\nMax temp: \(weatherData.main.tempMax) °C\nMin temp: \(weatherData.main.tempMin) °C\nDatetime: \(Date(timeIntervalSince1970: TimeInterval(weatherData.dt)))"
    }
    
    private var navigationItemTitle: String {
        "Weather in \(weatherData.name)"
    }
    
    init(view: WeatherDetailsViewDelegate, useCase: WeatherDataUseCase, weatherData: WeatherData) {
        self.view = view
        self.useCase = useCase
        self.weatherData = weatherData
    }
    
    func viewDidLoad() {
        view.setCityName(weatherData.name)
        view.setFavoriteButtonImage(Images.getStarImageFor(value: weatherData.isFavorited))
        view.setNavigationItemTitle(navigationItemTitle)
        view.setWeatherDescription(weatherDescription)
    }
    
    func updateFavoriteValue(completion: @escaping (_ newValue: Bool) -> Void) {
        let newValue = !weatherData.isFavorited
        useCase.setFavorited(value: newValue, for: weatherData) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.view.setFavoriteButtonImage(Images.getStarImageFor(value: newValue))
                self?.weatherData.isFavorited = newValue
                completion(newValue)
            case .failure(let error):
                self?.view.showError(error)
            }
        }
    }
    
}
