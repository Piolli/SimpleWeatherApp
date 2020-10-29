//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation

// MARK: - WeatherData
public struct WeatherData: Codable, Equatable {
    public let weather: [Weather]
    public let main: Main
    public let cod: Int
    public let sys: Sys
    public let coord: Coord
    public let base: String
    public let visibility: Int
    public let wind: Wind
    public let clouds: Clouds
    public let dt: Int
    public let timezone, id: Int
    public let name: String
}

// MARK: - Weather
public struct Weather: Codable, Equatable {
    public let id: Int
    public let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Main
public struct Main: Codable, Equatable {
    public let temp: Double
    public let feelsLike: Double
    public let tempMin, tempMax, pressure, humidity: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Clouds
public struct Clouds: Codable, Equatable {
    public let all: Int
}

// MARK: - Coord
public struct Coord: Codable, Equatable {
    public let lon, lat: Double
}

// MARK: - Sys
public struct Sys: Codable, Equatable {
    public let type, id: Int
    public let country: String
    public let sunrise, sunset: Int
}

// MARK: - Wind
public struct Wind: Codable, Equatable {
    public let speed, deg: Float
}
