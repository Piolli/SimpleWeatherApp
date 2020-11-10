import XCTest
@testable import LocalRepository
import Domain
import RealmSwift

final class LocalRepositoryTests: XCTestCase {
    
    var inMemoryRealmRepository: RealmRepository<WeatherData>!
    
    override func setUp() {
        let config = Realm.Configuration(inMemoryIdentifier: "ram")
        inMemoryRealmRepository = .init(configuration: config)
    }
    
    override func tearDown() {
        inMemoryRealmRepository = nil
    }
    
    func test_save_entity() {
        let exp = expectation(description: "object was saved")
        inMemoryRealmRepository.save(entity: WeatherData.TestData.sampleObject) { (result) in
            exp.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_save_entities() {
        let exp = expectation(description: "object was saved")
        exp.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            let object = WeatherData.TestData.sampleObjectWith(id: i)
            inMemoryRealmRepository.save(entity: object) { (result) in
                switch result {
                case .success(_):
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Object wasn't saved")
                }
            }
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    func test_queryAll_entities_success() {
        let exp = expectation(description: "objects was fetched")
        self.test_save_entities()
        
        // queryAll
        inMemoryRealmRepository.queryAll { (result) in
            switch result {
            case .success(let data):
                var i = 0
                data.forEach { (entity) in
                    XCTAssertEqual(entity.id, i)
                    i += 1
                }
                XCTAssertEqual(data.count, 10)
                exp.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_queryAll_entities_failure() {
        let exp = expectation(description: "objects wasn't fetched because local storage is empty")
        
        inMemoryRealmRepository.queryAll { (result) in
            switch result {
            case .success(_):
                XCTFail("Local storage must be empty")
            case .failure(let error):
                XCTAssertTrue(error == AppError.localStorageIsEmpty)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_delete_entity_success() {
        let exp = expectation(description: "objects was deleted")
        let sampleObject = WeatherData.TestData.sampleObject
        inMemoryRealmRepository.save(entity: sampleObject, {(_) in })
        
        inMemoryRealmRepository.delete(entity: sampleObject) { (result) in
            switch result {
            case .success(_):
                exp.fulfill()
            case .failure(_):
                XCTFail("Local storage doesn't have an entity")
            }
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_delete_entity_failure() {
        let exp = expectation(description: "objects wasn't deleted because doesn't exist")
        let sampleObject = WeatherData.TestData.sampleObject
        
        inMemoryRealmRepository.delete(entity: sampleObject) { (result) in
            switch result {
            case .success(_):
                XCTFail("Local storage must be empty")
            case .failure(let error):
                XCTAssertTrue(error == AppError.localStorageObjectNotExisted)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }

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
        
        public static func sampleObjectWith(id: Int) -> WeatherData {
            let object = sampleObject.asRealm()
            object.id = id
            return object.asDomain()
        }
    }
}
