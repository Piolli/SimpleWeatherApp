//
//  CitiesListPresenter.swift
//  SimpleWeatherApp
//
//  Created by Александр Камышев on 12.11.2020.
//

import Foundation
import Domain

protocol CitiesListPresenterProtocol {
    var router: CitiesListViewRouter { get }
    var numberOfCities: Int { get }
    func viewDidLoad()
    func removeWeatherData(at indexPath: IndexPath)
    func updateAllWeatherData()
    func addCity(_ cityName: String)
    func addCityButtonWasPressed()
    func didSelectRow(at indexPath: IndexPath)
    func configureCell(_ cell: CityCellView, at indexPath: IndexPath)
}


class CitiesListPresenter: CitiesListPresenterProtocol {
    func removeWeatherData(at indexPath: IndexPath) {
        let weatherData = weatherDataList[indexPath.row]
        useCase.remove(weatherData: weatherData) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(_):
                self.weatherDataList.remove(at: indexPath.row)
                self.view.removeRow(at: indexPath)
            case .failure(let error):
                self.view.showError(error)
            }
        }
    }
    
    func configureCell(_ cell: CityCellView, at indexPath: IndexPath) {
        let weatherData = weatherDataList[indexPath.row]
        cell.display(text: "\(weatherData.name) - \(weatherData.id)")
        cell.display(leadingImage: Images.getStarImageFor(value: weatherData.isFavorited))
    }
    
    var router: CitiesListViewRouter
    var weatherDataList: [Domain.WeatherData] = []
    unowned let view: CitiesListView
    let useCase: Domain.WeatherDataUseCase
    
    var numberOfCities: Int {
        return weatherDataList.count
    }
    
    init(view: CitiesListView, useCase: Domain.WeatherDataUseCase, router: CitiesListViewRouter) {
        self.view = view
        self.useCase = useCase
        self.router = router
    }
    
    func viewDidLoad() {
        loadLocalStorageCities()
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
                    self.view.setRefreshing(value: false)
                }
            case .failure(let error):
                self.view.showError(error)
            }
        }
    }
    
    func loadLocalStorageCities(_ completion: (() -> Void)? = nil) {
        useCase.localStorageWeather { [weak self] (result) in
            DispatchQueue.main.async {
                completion?()
                switch result {
                case .success(let citiesWithWeathers):
                    self?.showCities(citiesWithWeathers)
                case .failure(let error):
                    print("Error while loading local storage cities: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addCityButtonWasPressed() {
        view.showAddCityDialog()
    }
    
    func showCities(_ data: [WeatherData]) {
        weatherDataList.removeAll()
        weatherDataList.append(contentsOf: data)
        view.refreshCitiesView()
    }
    
    func add(weatherData: WeatherData) {
        weatherDataList.append(weatherData)
        view.insertRow(at: IndexPath(row: weatherDataList.count-1, section: 0))
    }

    func addCity(_ cityName: String) {
        useCase.weather(cityName: cityName) { [weak self] (result) in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self.add(weatherData: weatherData)
                case .failure(let error):
                    self.view.showError(error)
                }
            }
        }
    }
}

// MARK: - TableView
extension CitiesListPresenter: WeatherDetailsViewDelegate {
    func weatherDataWasSetFavorited(value: Bool, id: Int) {
        for i in weatherDataList.indices {
            let newValue = weatherDataList[i].id == id ? value : false
            weatherDataList[i].isFavorited = newValue
        }
        view.refreshCitiesView()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        router.presentWeatherDetailsViewController(with: weatherDataList[indexPath.row], delegate: self)
    }
}
