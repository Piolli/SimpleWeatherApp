//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation

// MARK: - WeatherData
public struct WeatherData: Codable {
    let weather: [Weather]
    let main: Main
    let cod: Int
    let sys: Sys
    let coord: Coord
    let base: String
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let timezone, id: Int
    let name: String
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Main
struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin, tempMax, pressure, humidity: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Sys
struct Sys: Codable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

// MARK: - Wind
struct Wind: Codable {
    let speed, deg: Float
}
