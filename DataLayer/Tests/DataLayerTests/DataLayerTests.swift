import XCTest
@testable import DataLayer
import RealmSwift
import Domain
import LocalRepository
import NetworkRepository

final class DataLayerTests: XCTestCase {
    
    var mockLocalRepository: Repository<WeatherData>!
    var mockNetworkRepository: Repository<WeatherData>!
    var weatherDataUseCase: Domain.WeatherDataUseCase!
    
    override func setUp() {
        super.setUp()
        let config = Realm.Configuration(inMemoryIdentifier: "ram1")
        mockLocalRepository = LocalRepository.RepositoryProvider(configuration: config).makeRepository()
        mockNetworkRepository = MockNetworkRepository()
        weatherDataUseCase = DataLayer.WeatherDataUseCase(networkRepository: mockNetworkRepository, localRepository: mockLocalRepository)
    }
    
    override func tearDown() {
        mockLocalRepository = nil
        mockNetworkRepository = nil
        weatherDataUseCase = nil
        super.tearDown()
    }
    
    // MARK: - Tests cases:
    // 1. No local -> Network
    // 2. Local -> No network
    // 3. No local -> No network
    // 4. Local -> Network
    func test_WeatherDataUseCase_EmptyLocalStorage_NetworkConnection_success() {
        let exp = expectation(description: "WeatherData was loaded")
        let sampleObject = WeatherData.TestData.sampleObject
        mockNetwork(with: .success([sampleObject]))
        weatherDataUseCase.weather(cityName: "Krasnoyarsk") { (result) in
            switch result {
            case .success(let weatherData):
                XCTAssertFalse(sampleObject.isFavorited)
                XCTAssertEqual(weatherData, sampleObject)
                exp.fulfill()
            case .failure(_):
                XCTFail("Network repository contains WeatherData object")
            }
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_WeatherDataUseCase_LocalStorage_NoNetworkConnection_success() {
        // save one sample object to local storage
        self.test_WeatherDataUseCase_EmptyLocalStorage_NetworkConnection_success()
        let exp = expectation(description: "WeatherData was loaded")
        let sampleObject = WeatherData.TestData.sampleObject
        mockNetwork(with: .failure(.networkWith(statusCode: 404)))
        
        weatherDataUseCase.weather(cityName: "Krasnoyarsk") { (result) in
            switch result {
            case .success(let weatherData):
                XCTAssertEqual(weatherData, sampleObject)
                exp.fulfill()
            case .failure(_):
                XCTFail("Network repository contains WeatherData object")
            }
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    func test_WeatherDataUseCase_EmptyLocalStorage_NoNetworkConnection_failure() {
        let exp = expectation(description: "WeatherData was loaded")
        mockNetwork(with: .failure(.networkWith(statusCode: 404)))
        weatherDataUseCase.weather(cityName: "Krasnoyarsk") { (result) in
            switch result {
            case .success(let data):
                dump(data)
                XCTFail("Network repository and local repository don't contain any objects")
            case .failure(let error):
                XCTAssertTrue(error == AppError.networkWith(statusCode: 404))
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_WeatherDataUseCase_LocalStorage_NetworkConnection_success() {
        // save one sample object to local storage
        self.test_WeatherDataUseCase_EmptyLocalStorage_NetworkConnection_success()
        let sampleObject = WeatherData.TestData.sampleObject
        let newDataSampleObject = WeatherData.TestData.emptyObjectWith(id: sampleObject.id, cityName: "Krasnoyarsk")
        mockNetwork(with: .success([newDataSampleObject]))
        
        let exp = expectation(description: "WeatherData from LocalStorage (load in background new data)")
        weatherDataUseCase.weather(cityName: "Krasnoyarsk") { (result) in
            switch result {
            case .success(let weatherData):
                XCTAssertEqual(weatherData, sampleObject)
                exp.fulfill()
            case .failure(_):
                XCTFail("Network repository contains WeatherData object")
            }
        }
        wait(for: [exp], timeout: 3.0)
        
        let exp1 = expectation(description: "WeatherData from Local Storage (auto updated weather data)")
        weatherDataUseCase.weather(cityName: "Krasnoyarsk") { (result) in
            switch result {
            case .success(let weatherData):
                XCTAssertEqual(weatherData, newDataSampleObject)
                exp1.fulfill()
            case .failure(_):
                XCTFail("Network repository contains WeatherData object")
            }
        }
        
        wait(for: [exp1], timeout: 3.0)
    }
    
    func test_WeatherDataUseCase_updateAllWeatherData_LocalStorage_NoNetworkConnection() {
        // save one sample object to local storage
        let exp = expectation(description: "WeatherData was loaded")
        let localObjects = [
            WeatherData.TestData.emptyObjectWith(id: 0, cityName: "Krasnoyarsk"),
            WeatherData.TestData.emptyObjectWith(id: 1, cityName: "Belgium"),
            WeatherData.TestData.emptyObjectWith(id: 2, cityName: "NY"),
        ]
        localObjects.forEach { (weatherData) in
            mockLocalRepository.save(entity: weatherData, {_ in})
        }
        mockNetwork(with: .failure(.networkWith(statusCode: 404)))
        
        weatherDataUseCase.updateAllWeatherData { (result) in
            switch result {
            case .success(_):
                break
            case .failure(_):
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    func test_WeatherDataUseCase_updateAllWeatherData_LocalStorage_NetworkConnection() {
        let exp = expectation(description: "WeatherData was loaded")
        mockLocalRepository.save(entity: WeatherData.TestData.emptyObjectWith(id: 0, cityName: "Belgium", dt: 0), {_ in})

        let networkObject = [WeatherData.TestData.emptyObjectWith(id: 0, cityName: "Belgium", dt: 199)]
        mockNetwork(with: .success(networkObject))
        
        weatherDataUseCase.updateAllWeatherData { (result) in
            switch result {
            case .success(_):
                self.weatherDataUseCase.localStorageWeather { (result) in
                    switch result {
                    case .success(let data):
                        XCTAssertEqual(data, networkObject)
                        exp.fulfill()
                    case .failure(_):
                        break
                    }
                }
            case .failure(_):
                break
            }
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    func test_WeatherDataUseCase_weather_True() {
        let exp = expectation(description: "WeatherData was loaded")
        var localObjects = [
            WeatherData.TestData.emptyObjectWith(id: 0, cityName: "Krasnoyarsk"),
            WeatherData.TestData.emptyObjectWith(id: 1, cityName: "Belgium"),
            WeatherData.TestData.emptyObjectWith(id: 2, cityName: "NY"),
        ]
        localObjects.forEach { (weatherData) in
            XCTAssertFalse(weatherData.isFavorited)
            mockLocalRepository.save(entity: weatherData, {_ in})
        }
        
        weatherDataUseCase.setFavorited(value: true, for: localObjects[0]) { (result) in
            switch result {
            case .success(_):
                exp.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        wait(for: [exp], timeout: 3.0)
        
        let exp1 = expectation(description: "WeatherData was loaded")
        
        weatherDataUseCase.localStorageWeather { (result) in
            switch result {
            case .success(let data):
                let favoritedData = data.filter { $0.isFavorited }
                XCTAssertEqual(favoritedData.count, 1)
                localObjects[0].isFavorited = true
                XCTAssertEqual(favoritedData[0], localObjects[0])
                exp1.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        
        wait(for: [exp1], timeout: 3.0)
    }
    
    func mockNetwork(with result: Result<[WeatherData], AppError>) {
        (mockNetworkRepository as! MockNetworkRepository).result = result
    }
    
}

class MockNetworkRepository<T>: Repository<T> {
    var result: Result<[T], AppError>?
    
    init(result: Result<[T], AppError>? = nil) {
        self.result = result
    }
    
    override func query(with predicate: NSPredicate, variables: [String : Any], _ completion: @escaping (Result<[T], AppError>) -> Void) {
        completion(result!)
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
        
        public static func emptyObjectWith(id: Int, cityName: String, dt: Int = 0) -> WeatherData {
            .init(isFavorited: false, weather: [], main: .init(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), cod: 0, sys: .init(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), coord: .init(lon: 0, lat: 0), base: "", visibility: 0, wind: .init(speed: 0, deg: 0), clouds: .init(all: 0), dt: dt, timezone: 0, id: id, name: cityName)
        }
    
    }
}
