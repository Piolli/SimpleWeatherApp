//
//  CitiesListPresenter.swift
//  SimpleWeatherApp
//
//  Created by Александр Камышев on 12.11.2020.
//

import Foundation
import Domain

class MockUseCase: Domain.WeatherDataUseCase {
    func weather(cityName: String, _ completion: @escaping (Result<WeatherData, AppError>) -> Void) {
        completion(.success(emptyObjectWith(id: 0, cityName: "Krasnoyarsk")))
    }
    
    func allLocalStorageWeatherData() -> [WeatherData] {
        return [
            emptyObjectWith(id: 0, cityName: "Krasnoyarsk"),
            emptyObjectWith(id: 1, cityName: "London"),
            emptyObjectWith(id: 2, cityName: "NY"),
            emptyObjectWith(id: 3, cityName: "Belgium"),
        ]
    }
    
    public  func emptyObjectWith(id: Int, cityName: String) -> WeatherData {
        .init(weather: [], main: .init(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), cod: 0, sys: .init(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), coord: .init(lon: 0, lat: 0), base: "", visibility: 0, wind: .init(speed: 0, deg: 0), clouds: .init(all: 0), dt: 0, timezone: 0, id: id, name: cityName)
    }
}

class CitiesListPresenter {
    unowned let delegate: CitiesListViewDelegate
    let useCase: Domain.WeatherDataUseCase
    
    init(delegate: CitiesListViewDelegate, useCase: Domain.WeatherDataUseCase) {
        self.delegate = delegate
        self.useCase = useCase
    }
    
    func loadLocalStorageCities() {
        // add allLocalStorageWeatherData() to WeatherDataUseCase
        let data = (useCase as! MockUseCase).allLocalStorageWeatherData()
        delegate.showCities(data)
    }
    
    func loadCity(_ cityName: String) {
        useCase.weather(cityName: cityName) { [weak self] (result) in
            guard let self = self else {
                return
            }
            // perform on main queue
            switch result {
            case .success(let citiesWithWeathers):
                self.delegate.addWeatherData(citiesWithWeathers)
            case .failure(let error):
                self.delegate.showError(error)
            }
        }
    }
    
}
