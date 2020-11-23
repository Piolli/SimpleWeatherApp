//
//  File.swift
//  
//
//  Created by Александр Камышев on 07.11.2020.
//

import Foundation
import RealmSwift
import Domain

class RMWeatherData: Object, DomainConvertible {
    let weather: List<RMWeather> = List()
    @objc dynamic public var isFavorited: Bool = false
    @objc dynamic public var main: RMMain?
    @objc dynamic public var cod: Int = 0
    @objc dynamic public var sys: RMSys?
    @objc dynamic public var coord: RMCoord?
    @objc dynamic public var base: String = ""
    @objc dynamic public var visibility: Int = 0
    @objc dynamic public var wind: RMWind?
    @objc dynamic public var clouds: RMClouds?
    @objc dynamic public var dt: Int = 0
    @objc dynamic public var id: Int = 0
    @objc dynamic public var timezone: Int = 0
    @objc dynamic public var name: String = ""
    
    override init() {
        super.init()
    }
    
    public init(isFavorited: Bool = false, main: RMMain? = nil, cod: Int = 0, sys: RMSys? = nil, coord: RMCoord? = nil, base: String = "", visibility: Int = 0, wind: RMWind? = nil, clouds: RMClouds? = nil, dt: Int = 0, id: Int = 0, timezone: Int = 0, name: String = "") {
        self.isFavorited = isFavorited
        self.main = main
        self.cod = cod
        self.sys = sys
        self.coord = coord
        self.base = base
        self.visibility = visibility
        self.wind = wind
        self.clouds = clouds
        self.dt = dt
        self.id = id
        self.timezone = timezone
        self.name = name
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func asDomain() -> WeatherData {
        let weathers = Array(weather.map {$0.asDomain()})
        return WeatherData(isFavorited: isFavorited, weather: weathers, main: main!.asDomain(), cod: cod, sys: sys!.asDomain(), coord: coord!.asDomain(), base: base, visibility: visibility, wind: wind!.asDomain(), clouds: clouds!.asDomain(), dt: dt, timezone: timezone, id: id, name: name)
    }
}

// MARK: - Weather
public class RMWeather: Object {
    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
    
    @objc dynamic public var id: Int = 0
    @objc dynamic public var main: String = ""
    @objc dynamic public var weatherDescription: String = ""
    @objc dynamic public var icon: String = ""

    public override class func primaryKey() -> String? {
        return "id"
    }
    
    override init() {
        super.init()
    }
    
    public init(id: Int, main: String, weatherDescription: String, icon: String) {
        self.id = id
        self.main = main
        self.weatherDescription = weatherDescription
        self.icon = icon
    }
}

extension RMWeather: DomainConvertible {
    func asDomain() -> Weather {
        return Weather(id: id, main: main, weatherDescription: weatherDescription, icon: icon)
    }
}

// MARK: - Main
public class RMMain: Object {
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
    
    @objc dynamic public var temp: Double = 0.0
    @objc dynamic public var feelsLike: Double = 0.0
    @objc dynamic public var tempMin: Double = 0.0
    @objc dynamic public var tempMax: Double = 0.0
    @objc dynamic public var pressure: Double = 0.0
    @objc dynamic public var humidity: Double = 0.0
    
    override init() {
        super.init()
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

extension RMMain: DomainConvertible {
    func asDomain() -> Main {
        return Main(temp: temp, feelsLike: feelsLike, tempMin: tempMin, tempMax: tempMax, pressure: pressure, humidity: humidity)
    }
}

// MARK: - Clouds
public class RMClouds: Object{
    @objc dynamic public var all: Int = 0
    
    override init() {
        super.init()
    }
    
    public init(all: Int) {
        self.all = all
    }
    
}

extension RMClouds: DomainConvertible {
    func asDomain() -> Clouds {
        return Clouds(all: all)
    }
}

// MARK: - Coord
public class RMCoord: Object {
    @objc dynamic public var lat: Double = 0.0
    @objc dynamic public var lon: Double = 0.0
    
    override init() {
        super.init()
    }
    
    public init(lon: Double, lat: Double) {
        self.lon = lon
        self.lat = lat
    }
}

extension RMCoord: DomainConvertible {
    func asDomain() -> Coord {
        return Coord(lon: lon, lat: lat)
    }
}

// MARK: - Sys
public class RMSys: Object {
    @objc dynamic public var id: Int = 0
    @objc dynamic public var type: Int = 0
    @objc dynamic public var country: String = ""
    @objc dynamic public var sunset: Int = 0
    @objc dynamic public var sunrise: Int = 0
    
    public override class func primaryKey() -> String? {
        return "id"
    }

    override init() {
        super.init()
    }
    
    public init(type: Int, id: Int, country: String, sunrise: Int, sunset: Int) {
        self.type = type
        self.id = id
        self.country = country
        self.sunrise = sunrise
        self.sunset = sunset
    }
}

extension RMSys: DomainConvertible {
    func asDomain() -> Sys {
        return Sys(type: type, id: id, country: country, sunrise: sunrise, sunset: sunset)
    }
}

// MARK: - Wind
public class RMWind: Object {
    @objc dynamic public var deg: Float = 0.0
    @objc dynamic public var speed: Float = 0.0
    
    override init() {
        super.init()
    }
    
    public init(speed: Float, deg: Float) {
        self.speed = speed
        self.deg = deg
    }
}

extension RMWind: DomainConvertible {
    func asDomain() -> Wind {
        return Wind(speed: speed, deg: deg)
    }
}

extension WeatherData: RealmRepresentable {
    func asRealm() -> RMWeatherData {
        let weatherData = RMWeatherData(isFavorited: isFavorited, main: main.asRealm(), cod: cod, sys: sys.asRealm(), coord: coord.asRealm(), base: base, visibility: visibility, wind: wind.asRealm(), clouds: clouds.asRealm(), dt: dt, id: id, timezone: timezone, name: name)
        weatherData.weather.append(objectsIn: weather.map { $0.asRealm() })
        return weatherData
    }
}

extension Weather: RealmRepresentable {
    func asRealm() -> RMWeather {
        return RMWeather(id: id, main: main, weatherDescription: weatherDescription, icon: icon)
    }
}

extension Main: RealmRepresentable {
    var id: Int {
        -1
    }
    
    func asRealm() -> RMMain {
        return RMMain(temp: temp, feelsLike: feelsLike, tempMin: tempMin, tempMax: tempMax, pressure: pressure, humidity: humidity)
    }
}

extension Clouds: RealmRepresentable {
    var id: Int {
        -1
    }
    
    func asRealm() -> RMClouds {
        return RMClouds(all: all)
    }
}

extension Coord: RealmRepresentable {
    var id: Int {
        -1
    }
    
    func asRealm() -> RMCoord {
        return RMCoord(lon: lon, lat: lat)
    }
}

extension Sys: RealmRepresentable {
    func asRealm() -> RMSys {
        return RMSys(type: type, id: id, country: country, sunrise: sunrise, sunset: sunset)
    }
}

extension Wind: RealmRepresentable {
    var id: Int {
        -1
    }
    
    func asRealm() -> RMWind {
        return RMWind(speed: speed, deg: deg)
    }
}
