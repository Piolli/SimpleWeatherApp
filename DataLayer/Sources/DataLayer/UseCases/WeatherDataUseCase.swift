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
                    wd.isFavorited = false
                    self.saveToLocalStorage(wd)
                }
            case .failure(let error):
                completion(.failure(.localStorageWith(error)))
            }
        }
        
        var weatherData = weatherData
        weatherData.isFavorited = value
        localRepository.save(entity: weatherData, completion)
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
//                completion(.failure(.localStorageWith(error)))
            }
        }
        
        dispathGroup.notify(queue: DispatchQueue.main) {
            completion(outputError == nil ? .success(()) : .failure(.localStorageWith(outputError!)))
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
            switch result {
            case .success(let weathers):
                let weatherData = weathers.first!
                completion(.success(weatherData))
                self?.saveToLocalStorage(weatherData)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func saveToLocalStorage(_ weatherData: WeatherData) {
        localRepository.save(entity: weatherData) { (result) in
            switch result {
            case .success():
                print("WeatherData was saved to LocalStorage with id = \(weatherData.id) and dt: \(weatherData.dt)")
            case .failure(let error):
                print("Error: WeatherData wasn't saved to LocalStorage with id = \(weatherData.id): \(error)")
            }
        }
    }
}
