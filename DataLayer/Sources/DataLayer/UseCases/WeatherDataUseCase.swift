//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation
import Domain

public class WeatherDataUseCase: Domain.WeatherDataUseCase {
    
    public func weather(_ completion: (Result<WeatherData, AppError>) -> Void) {
        fatalError("weather(_:) has not been implemented")
    }
    
}
