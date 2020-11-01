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
    public func makeRepository() -> Repository<WeatherData> {
        let network = AFNetwork(endpoint: "http://api.openweathermap.org/data/2.5/", apiKey: "c0e92eab71cf0f8bc631518dbd6cf7f3")
        let repository = NetworkRepository(network: network)
        return repository
    }
}
