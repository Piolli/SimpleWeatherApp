//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation
import Domain

public final class UseCaseProvider: Domain.UseCaseProvider {
    
    public init() {
        
    }
    
    public func makeWeatherDataUseCase() -> Domain.WeatherDataUseCase {
        return WeatherDataUseCase()
    }
}
