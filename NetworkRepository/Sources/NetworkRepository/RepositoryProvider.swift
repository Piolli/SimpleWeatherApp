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
        fatalError("makeRepository() has not been implemented")
    }
}
