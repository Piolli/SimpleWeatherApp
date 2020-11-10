//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation

public protocol WeatherDataUseCase {
    
    func weather(cityName: String, _ completion: @escaping (Result<WeatherData, AppError>) -> Void)
    
}
