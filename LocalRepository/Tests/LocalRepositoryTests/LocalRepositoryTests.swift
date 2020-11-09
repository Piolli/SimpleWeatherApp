import XCTest
@testable import LocalRepository
import Domain
import RealmSwift


final class LocalRepositoryTests: XCTestCase {
    static var allTests = [
        ("test_RealmRepresentable_WeatherData", test_RealmRepresentable_WeatherData),
    ]

    func test_RealmRepresentable_WeatherData() {
        let sampleObject = WeatherData.TestData.sampleObject
        let realmObject = sampleObject.asRealm()
        XCTAssertEqual(realmObject.weather.count, 1)
        XCTAssertEqual(realmObject.name, "Krasnoyarsk")
        XCTAssertEqual(realmObject.coord?.lon, 92.79)
        XCTAssertEqual(realmObject.main?.tempMin, 278.15)
        XCTAssertEqual(realmObject.id, 1502026)
    }

    func test_DomainConvertible_RMWeatherData() {
        let realmObject = RMWeatherData(main: .init(), cod: 200, sys: .init(), coord: .init(lon: 100, lat: 200), base: "base", visibility: 100, wind: .init(), clouds: .init(), dt: 0, id: 150, timezone: 200, name: "name")
        realmObject.weather.append(RMWeather())
        realmObject.weather.append(RMWeather())
        let domainObject = realmObject.asDomain()

        XCTAssertEqual(domainObject.weather.count, 2)
        XCTAssertEqual(domainObject.name, "name")
        XCTAssertEqual(domainObject.coord.lon, 100)
        XCTAssertEqual(domainObject.id, 150)
    }
}

// MARK: - Sample WeatherData
private extension WeatherData {
    enum TestData {
        public static var sampleJSON: String {
            return
                """
                {"coord":{"lon":92.79,"lat":56.01},"weather":[{"id":520,"main":"Rain","description":"light intensity shower rain","icon":"09d"}],"base":"stations","main":{"temp":278.15,"feels_like":272.42,"temp_min":278.15,"temp_max":278.15,"pressure":1007,"humidity":86},"visibility":10000,"wind":{"speed":6,"deg":270},"clouds":{"all":75},"dt":1603876878,"sys":{"type":1,"id":8957,"country":"RU","sunrise":1603846041,"sunset":1603880261},"timezone":25200,"id":1502026,"name":"Krasnoyarsk","cod":200}
                """
        }
        
        public static var sampleObject: WeatherData {
            let data = sampleJSON.data(using: .utf8)
            let weatherData = try! JSONDecoder().decode(WeatherData.self, from: data!)
            return weatherData
        }
        
    }
}

