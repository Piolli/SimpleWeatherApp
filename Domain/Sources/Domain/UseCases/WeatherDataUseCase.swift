//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation

public protocol WeatherDataUseCase {
    
    func weather(cityName: String, _ completion: @escaping (Result<WeatherData, AppError>) -> Void)
    
    func localStorageWeather(completion: @escaping (Result<[WeatherData], AppError>) -> Void)
    
    func updateAllWeatherData(completion: @escaping (Result<Void, AppError>) -> Void)
    
    func setFavorited(value: Bool, for weatherData: WeatherData, completion: @escaping (Result<Void, AppError>) -> Void)
    
    func remove(weatherData: WeatherData, completion: @escaping (Result<Void, AppError>) -> Void)
    
}
