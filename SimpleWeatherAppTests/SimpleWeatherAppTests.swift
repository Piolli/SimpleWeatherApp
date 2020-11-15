//
//  SimpleWeatherAppTests.swift
//  SimpleWeatherAppTests
//
//  Created by Александр Камышев on 28.10.2020.
//

import XCTest
@testable import SimpleWeatherApp
import Domain

class SimpleWeatherAppTests: XCTestCase {

    var presenter: CitiesListPresenter!
    var view: MockCitiesListView!
    var useCase: MockUseCase!
    
    override func setUp() {
        super.setUp()
        view = MockCitiesListView()
        useCase = MockUseCase()
        presenter = CitiesListPresenter(delegate: view, useCase: useCase)
    }
    
    override func tearDown() {
        view = nil
        presenter = nil
        super.tearDown()
    }
    
    func test_presenter_loadLocalStorageCities_view_showCities() {
        let exp = expectation(description: "Method was called")
        let localWeatherDataList = [
            MockUseCase.emptyObjectWith(id: 0, cityName: "Krasnoyarsk"),
            MockUseCase.emptyObjectWith(id: 1, cityName: "London"),
            MockUseCase.emptyObjectWith(id: 2, cityName: "NY"),
            MockUseCase.emptyObjectWith(id: 3, cityName: "Belgium"),
        ]
        useCase.localStorageWeatherResult = .success(localWeatherDataList)
        
        view.showCitiesMethod = { result in
            XCTAssertEqual(localWeatherDataList, result)
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        }
        
        presenter.loadLocalStorageCities()
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_presenter_loadLocalStorageCities_view_showError() {
        let exp = expectation(description: "Method was called")
        useCase.localStorageWeatherResult = .failure(.localStorageIsEmpty)
        
        view.showErrorMethod = { error in
            XCTAssertEqual(error.localizedDescription, AppError.localStorageIsEmpty.localizedDescription)
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        }
        
        presenter.loadLocalStorageCities()
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_presenter_loadCity_view_addWeatherData() {
        let exp = expectation(description: "Method was called")
        let weatherData = MockUseCase.emptyObjectWith(id: 0, cityName: "Krasnoyarsk")
        useCase.weatherMethodResult = .success(weatherData)
        
        view.addWeatherData = { data in
            XCTAssertEqual(weatherData, data)
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        }
        
        presenter.loadCity("Krasnoyarsk")
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func test_presenter_loadCity_view_showError() {
        let exp = expectation(description: "Method was called")
        useCase.weatherMethodResult = .failure(.localStorageIsEmpty)
        
        view.showErrorMethod = { error in
            XCTAssertEqual(error.localizedDescription, AppError.localStorageIsEmpty.localizedDescription)
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        }
        
        presenter.loadCity("Krasnoyarsk")
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_presenter_updateAllWeatherData_view_showCities() {
        let exp = expectation(description: "Method was called")
        exp.expectedFulfillmentCount = 2
        let localWeatherDataList = [
            MockUseCase.emptyObjectWith(id: 0, cityName: "Krasnoyarsk", dt: 0),
            MockUseCase.emptyObjectWith(id: 1, cityName: "London", dt: 0),
            MockUseCase.emptyObjectWith(id: 2, cityName: "NY", dt: 0),
            MockUseCase.emptyObjectWith(id: 3, cityName: "Belgium", dt: 0),
        ]
        useCase.localStorageWeatherResult = .success(localWeatherDataList)
        useCase.updateAllWeatherDataResult = .success(Void())
        
        view.showCitiesMethod = { result in
            XCTAssertEqual(localWeatherDataList, result)
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        }
        
        presenter.updateAllWeatherData(completion: {
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func test_presenter_updateAllWeatherData_view_showError() {
        let exp = expectation(description: "Method was called")
        exp.expectedFulfillmentCount = 2
        let localWeatherDataList = [
            MockUseCase.emptyObjectWith(id: 0, cityName: "Krasnoyarsk", dt: 0),
            MockUseCase.emptyObjectWith(id: 1, cityName: "London", dt: 0),
            MockUseCase.emptyObjectWith(id: 2, cityName: "NY", dt: 0),
            MockUseCase.emptyObjectWith(id: 3, cityName: "Belgium", dt: 0),
        ]
        useCase.localStorageWeatherResult = .success(localWeatherDataList)
        useCase.updateAllWeatherDataResult = .failure(.localStorageIsEmpty)
        
        view.showErrorMethod = { error in
            XCTAssertTrue(error.localizedDescription == AppError.localStorageIsEmpty.localizedDescription)
            exp.fulfill()
        }
        
        presenter.updateAllWeatherData(completion: {
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
}

class MockUseCase: Domain.WeatherDataUseCase {
    
    var localStorageWeatherResult: Result<[WeatherData], AppError>?
    var weatherMethodResult: Result<WeatherData, AppError>?
    var updateAllWeatherDataResult: Result<Void, AppError>?
    
    func weather(cityName: String, _ completion: @escaping (Result<WeatherData, AppError>) -> Void) {
        completion(weatherMethodResult!)
    }
    
    func localStorageWeather(completion: @escaping (Result<[WeatherData], AppError>) -> Void) {
        completion(localStorageWeatherResult!)
    }
    
    func updateAllWeatherData(completion: @escaping (Result<Void, AppError>) -> Void) {
        completion(updateAllWeatherDataResult!)
    }
    
    public static func emptyObjectWith(id: Int, cityName: String, dt: Int? = nil) -> WeatherData {
        .init(weather: [], main: .init(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), cod: 0, sys: .init(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), coord: .init(lon: 0, lat: 0), base: "", visibility: 0, wind: .init(speed: 0, deg: 0), clouds: .init(all: 0), dt: dt ?? 0, timezone: 0, id: id, name: cityName)
    }
}

class MockCitiesListView: SimpleWeatherApp.CitiesListViewDelegate {
    var showCitiesMethod: (([WeatherData]) -> Void)?
    var showErrorMethod: ((AppError) -> Void)?
    var addWeatherData: ((WeatherData) -> Void)?
    
    func showCities(_ cities: [WeatherData]) {
        showCitiesMethod?(cities)
    }
    
    func showError(_ error: AppError) {
        showErrorMethod?(error)
    }
    
    func addWeatherData(_ weatherData: WeatherData) {
        addWeatherData?(weatherData)
    }
}
