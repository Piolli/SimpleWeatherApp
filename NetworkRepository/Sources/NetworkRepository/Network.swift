//
//  File.swift
//  
//
//  Created by Александр Камышев on 31.10.2020.
//

import Foundation
import Domain

protocol Network {
    func fetchWeatherData(cityName: String, completion: @escaping (Result<WeatherData, AppError>) -> Void)
}
