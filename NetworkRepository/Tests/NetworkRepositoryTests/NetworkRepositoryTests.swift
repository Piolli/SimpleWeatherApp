import XCTest
import Mocker
import Alamofire
@testable import NetworkRepository
@testable import Domain

final class NetworkRepositoryTests: XCTestCase {
    
    let mockedEndpoint = ""
    let apiKey = ""
    
    private lazy var repository: Repository<Domain.WeatherData> = {
        let session = mockURLProtocol()
        return NetworkRepository(network: AFNetwork(endpoint: mockedEndpoint, apiKey: apiKey, session: session))
    }()
    
    func mockURLProtocol() -> Alamofire.Session {
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [MockingURLProtocol.self] + (config.protocolClasses ?? [])
        return Session(configuration: config)
    }
    
    func test_Network_returns_WeatherData_success_result() {
        let exp = expectation(description: "weather has been loaded")
        let variables = ["name": "Krasnoyarsk"]
        let responseData = WeatherData.TestData.sampleJSON.data(using: .utf8)!
        
        let endpoint = mockedEndpoint.appending("/weather?appid=\(apiKey)&q=\(variables["name"]!)&units=metric")
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.get: responseData])
        mock.register()
        
        repository.query(with: NSPredicate(format: "name == $name"), variables: variables) { (result) in
            switch result {
            case .success(_):
                exp.fulfill()
                break
            case .failure(_):
                break
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_Network_returns_WeatherData_failrure_result() {
        let exp = expectation(description: "weather hasn't loaded")
        let variables = ["name": "Krasnoyars"]
        
        let endpoint = mockedEndpoint.appending("/weather?appid=\(apiKey)&q=\(variables["name"]!)&units=metric")
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 204, data: [.get: Data()])
        mock.register()
        
        repository.query(with: NSPredicate(format: "name == $name"), variables: variables) { (result) in
            switch result {
            case .success(_):
                break
            case .failure(_):
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    static var allTests = [
        ("test_Network_returns_WeatherData_result", test_Network_returns_WeatherData_success_result),
    ]
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
