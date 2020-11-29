//
//  CitiesListPresenter.swift
//  SimpleWeatherApp
//
//  Created by Александр Камышев on 12.11.2020.
//

import Foundation
import Domain

class CitiesListPresenter {
    unowned let delegate: CitiesListViewDelegate
    let useCase: Domain.WeatherDataUseCase
    
    init(delegate: CitiesListViewDelegate, useCase: Domain.WeatherDataUseCase) {
        self.delegate = delegate
        self.useCase = useCase
    }
    
    func updateAllWeatherData() {
        useCase.updateAllWeatherData { [weak self] (result) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(_):
                print("All local weather data were updated")
                self.loadLocalStorageCities {
                    self.delegate.setRefreshing(value: false)
                }
            case .failure(let error):
                self.delegate.showError(error)
            }
        }
    }
    
    func loadLocalStorageCities(_ completion: (() -> Void)? = nil) {
        useCase.localStorageWeather { (result) in
            DispatchQueue.main.async {
                completion?()
                switch result {
                case .success(let citiesWithWeathers):
                    self.delegate.showCities(citiesWithWeathers)
                case .failure(let error):
                    print("Error while loading local storage cities: \(error.localizedDescription)")
                }
            }
        }
    }

    func loadCity(_ cityName: String) {
        useCase.weather(cityName: cityName) { [weak self] (result) in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let citiesWithWeathers):
                    self.delegate.addWeatherData(citiesWithWeathers)
                case .failure(let error):
                    self.delegate.showError(error)
                }
            }
        }
    }
    
    func remove(weatherData: WeatherData, completion: @escaping (Result<Void, AppError>) -> Void) {
        useCase.remove(weatherData: weatherData, completion: completion)
    }
}
