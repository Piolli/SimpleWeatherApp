import XCTest
@testable import Domain

private final class DomainTests: XCTestCase {
    static var allTests = [
        ("testJSONParsing", testJSONParsing),
    ]
    
    func testJSONParsing() throws {
        let json = """
{"coord":{"lon":92.79,"lat":56.01},"weather":[{"id":520,"main":"Rain","description":"light intensity shower rain","icon":"09d"}],"base":"stations","main":{"temp":278.15,"feels_like":272.42,"temp_min":278.15,"temp_max":278.15,"pressure":1007,"humidity":86},"visibility":10000,"wind":{"speed":6,"deg":270},"clouds":{"all":75},"dt":1603876878,"sys":{"type":1,"id":8957,"country":"RU","sunrise":1603846041,"sunset":1603880261},"timezone":25200,"id":1502026,"name":"Krasnoyarsk","cod":200}
"""
        let data = json.data(using: .utf8)
        XCTAssertNotNil(data)
        let weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
        
        //test some type's members
        XCTAssertEqual(weatherData.cod, 200)
        XCTAssertEqual(weatherData.id, 1502026)
        XCTAssertEqual(weatherData.main.temp, 278.15)
        XCTAssertEqual(weatherData.name, "Krasnoyarsk")
        
    }
}
