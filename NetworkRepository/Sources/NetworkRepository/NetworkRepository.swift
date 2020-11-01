//
//  File.swift
//  
//
//  Created by Александр Камышев on 30.10.2020.
//

import Foundation
import Domain

class NetworkRepository: Domain.Repository<WeatherData> {
    
    let network: Network

    init(network: Network) {
        self.network = network
    }
    
    override func queryAll(_ completion: @escaping (Result<[WeatherData], AppError>) -> Void) {
        super.queryAll(completion)
    }
    
    override func query(with predicate: NSPredicate, variables: [String: Any], _ completion: @escaping (Result<[WeatherData], AppError>) -> Void) {
        if let name = variables["name"] as? String {
            network.fetchWeatherData(cityName: name) { result in
                // transform single value to array
                completion(result.map { [$0] })
            }
        }
    }
    
    override func save(entity: WeatherData, _ completion: @escaping (Result<Void, AppError>) -> Void) {
        super.save(entity: entity, completion)
    }
    
    override func delete(entity: WeatherData, _ completion: @escaping (Result<Void, AppError>) -> Void) {
        super.delete(entity: entity, completion)
    }
}
