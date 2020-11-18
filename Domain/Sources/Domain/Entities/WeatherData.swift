//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation

// MARK: - WeatherData
public struct WeatherData: Codable, Equatable {
    // untracked for JSON
    public var isFavorite: Bool! = false
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
    
    public init(isFavorite: Bool, weather: [Weather], main: Main, cod: Int, sys: Sys, coord: Coord, base: String, visibility: Int, wind: Wind, clouds: Clouds, dt: Int, timezone: Int, id: Int, name: String) {
        self.isFavorite = isFavorite
        self.weather = weather
        self.main = main
        self.cod = cod
        self.sys = sys
        self.coord = coord
        self.base = base
        self.visibility = visibility
        self.wind = wind
        self.clouds = clouds
        self.dt = dt
        self.timezone = timezone
        self.id = id
        self.name = name
    }
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
    
    public init(id: Int, main: String, weatherDescription: String, icon: String) {
        self.id = id
        self.main = main
        self.weatherDescription = weatherDescription
        self.icon = icon
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
    
    public init(temp: Double, feelsLike: Double, tempMin: Double, tempMax: Double, pressure: Double, humidity: Double) {
        self.temp = temp
        self.feelsLike = feelsLike
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.pressure = pressure
        self.humidity = humidity
    }
}

// MARK: - Clouds
public struct Clouds: Codable, Equatable {
    public let all: Int
    
    public init(all: Int) {
        self.all = all
    }
}

// MARK: - Coord
public struct Coord: Codable, Equatable {
    public let lon, lat: Double
    
    public init(lon: Double, lat: Double) {
        self.lon = lon
        self.lat = lat
    }
}

// MARK: - Sys
public struct Sys: Codable, Equatable {
    public let type, id: Int
    public let country: String
    public let sunrise, sunset: Int

    public init(type: Int, id: Int, country: String, sunrise: Int, sunset: Int) {
        self.type = type
        self.id = id
        self.country = country
        self.sunrise = sunrise
        self.sunset = sunset
    }
}

// MARK: - Wind
public struct Wind: Codable, Equatable {
    public let speed, deg: Float
    
    public init(speed: Float, deg: Float) {
        self.speed = speed
        self.deg = deg
    }
}
