import XCTest
@testable import DataLayer
import RealmSwift
import Domain

final class DataLayerTests: XCTestCase {
    
    
    
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
