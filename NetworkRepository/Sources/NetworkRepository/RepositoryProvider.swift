//
//  File.swift
//  
//
//  Created by Александр Камышев on 30.10.2020.
//

import Foundation

import Foundation
import Domain

public class RepositoryProvider: Domain.RepositoryProvider {
    
    public init() { }
    
    public func makeRepository() -> Repository<WeatherData> {
        let network = AFNetwork(endpoint: "http://api.openweathermap.org/data/2.5/", apiKey: "YOUR_API_KEY")
        let repository = NetworkRepository(network: network)
        return repository
    }
}
