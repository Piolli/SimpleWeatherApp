//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation
import Domain
import LocalRepository
import NetworkRepository
import WidgetKit

public class WeatherDataUseCase: Domain.WeatherDataUseCase {
    
    let networkRepository: Repository<WeatherData>
    let localRepository: Repository<WeatherData>
    
    public init(networkRepository: Repository<WeatherData> = NetworkRepository.RepositoryProvider().makeRepository(), localRepository: Repository<WeatherData> = LocalRepository.RepositoryProvider().makeRepository()) {
        self.networkRepository = networkRepository
        self.localRepository = localRepository
    }
    
    public func weather(cityName: String, _ completion: @escaping (Result<WeatherData, AppError>) -> Void) {
        let predicate = NSPredicate(format: "name == $name")
        let input = ["name": cityName]
        localRepository.query(with: predicate, variables: input) { [weak self] (result) in
            guard let self = self else {
                completion(.failure(.unknown))
                return
            }
            switch result {
            case .success(let weathers):
                completion(.success(weathers.first!))
                self.updateWeatherDataInBackground(predicate: predicate, input: input, cityName: cityName)
            case .failure(let error):
                print("Local storage:", error)
                //try to load from remote repository
                self.fetchFromNetworkRepository(predicate: predicate, input: input, cityName: cityName, completion)
            }
        }
    }
    
    public func setFavorited(value: Bool, for weatherData: WeatherData, completion: @escaping (Result<Void, AppError>) -> Void) {
        //set previous weather data to unfavorite
        localStorageWeather { [weak self] (result) in
            guard let self = self else {
                completion(.failure(.unknown))
                return
            }
            switch result {
            case .success(let data):
                for var wd in data {
                    if wd.id == weatherData.id {
                        wd.isFavorited = value
                        self.saveToLocalStorage(wd, completion: completion)
                    } else if wd.isFavorited  {
                        wd.isFavorited = false
                        self.saveToLocalStorage(wd)
                    }
                }
                WeatherDataUseCase.updateWidgetState()
            case .failure(let error):
                completion(.failure(.localStorageWith(error)))
            }
        }
    }
    
    public func remove(weatherData: WeatherData, completion: @escaping (Result<Void, AppError>) -> Void) {
        localRepository.delete(entity: weatherData) { (result) in
            switch result {
            case .success(_):
                WeatherDataUseCase.updateWidgetState()
            case .failure(_):
                break
            }
            completion(result)
        }
    }
    
    public func localStorageWeather(completion: @escaping (Result<[WeatherData], AppError>) -> Void) {
        localRepository.queryAll(completion)
    }
    
    public func updateAllWeatherData(completion: @escaping (Result<Void, AppError>) -> Void) {
        let dispathGroup = DispatchGroup()
        var outputError: AppError?
        localStorageWeather { (result) in
            switch result {
            case .success(let weatherDataList):
                for weatherData in weatherDataList {
                    dispathGroup.enter()
                    self.updateWeatherDataInBackground(cityName: weatherData.name) { (result) in
                        switch result {
                        case .success(_):
                            break
                        case .failure(let error):
                            outputError = .networkWith(error, statusCode: error.asAFError?.responseCode ?? 0)
                        }
                        dispathGroup.leave()
                    }
                }
            case .failure(let error):
                outputError = .localStorageWith(error)
            }
        }
        
        dispathGroup.notify(queue: DispatchQueue.main) {
            if outputError == nil {
                completion(.success(()))
                WeatherDataUseCase.updateWidgetState()
            } else {
                completion(.failure(.localStorageWith(outputError!)))
            }
        }
    }
    
    private static func updateWidgetState() {
        if #available(iOS 14, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func updateWeatherDataInBackground(cityName: String, _ completion: ( (Result<WeatherData, AppError>) -> Void)? = nil) {
        let predicate = NSPredicate(format: "name == $name")
        let input = ["name": cityName]
        updateWeatherDataInBackground(predicate: predicate, input: input, cityName: cityName, completion)
    }
    
    private func updateWeatherDataInBackground(predicate: NSPredicate, input: [String: Any], cityName: String, _ completion: ( (Result<WeatherData, AppError>) -> Void)? = nil) {
        fetchFromNetworkRepository(predicate: predicate, input: input, cityName: cityName, completion ?? { _ in })
    }
    
    private func fetchFromNetworkRepository(predicate: NSPredicate, input: [String: Any], cityName: String, _ completion: @escaping (Result<WeatherData, AppError>) -> Void) {
        networkRepository.query(with: predicate, variables: input) { [weak self] (result) in
            guard let self = self else {
                completion(.failure(.unknown))
                return
            }
            switch result {
            case .success(let weathers):
                var weatherData = weathers.first!
                completion(.success(weatherData))
                // check if weather data exists
                self.localRepository.query(with: predicate, variables: input) { (result) in
                    switch result {
                    case .success(let data):
                        // use saved state because network weather data removes local state
                        weatherData.isFavorited = data.first!.isFavorited
                    case .failure(_):
                        break
                    }
                    self.saveToLocalStorage(weatherData)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func saveToLocalStorage(_ weatherData: WeatherData, completion: ((Result<Void, AppError>) -> Void)? = nil) {
        localRepository.save(entity: weatherData) { (result) in
            switch result {
            case .success():
                completion?(.success(()))
                print("WeatherData was saved to LocalStorage with id = \(weatherData.id) and dt: \(weatherData.dt)")
            case .failure(let error):
                completion?(.failure(.localStorageWith(error)))
                print("Error: WeatherData wasn't saved to LocalStorage with id = \(weatherData.id): \(error)")
            }
        }
    }
}
