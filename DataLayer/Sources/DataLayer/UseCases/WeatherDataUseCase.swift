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
        let input = ["name": "Krasnoyarsk"]
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
                print("Error:", error)
                //try to load from remote repository
                self.fetchFromNetworkRepository(predicate: predicate, input: input, cityName: cityName, completion)
            }
        }
    }
    
    public func localStorageWeather(completion: @escaping (Result<[WeatherData], AppError>) -> Void) {
        localRepository.queryAll(completion)
    }
    
    private func updateWeatherDataInBackground(predicate: NSPredicate, input: [String: Any], cityName: String) {
        fetchFromNetworkRepository(predicate: predicate, input: input, cityName: cityName) { _ in }
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
                print("WeatherData was saved to LocalStorage with id = \(weatherData.id)")
            case .failure(let error):
                print("Error: WeatherData wasn't saved to LocalStorage with id = \(weatherData.id): \(error)")
            }
        }
    }
}
