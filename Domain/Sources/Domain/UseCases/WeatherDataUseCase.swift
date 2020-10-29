//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation

public protocol WeatherDataUseCase {
    
    func weather(_ completion: (Result<WeatherData, AppError>) -> Void)
    
}
