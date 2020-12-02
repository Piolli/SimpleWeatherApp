//
//  CitiesListViewRouter.swift
//  SimpleWeatherApp
//
//  Created by Alexandr Kamyshev on 30.11.2020.
//

import Foundation
import Domain
import DataLayer
import UIKit

protocol CitiesListViewRouterProtocol: ViewRouter {
    func presentWeatherDetailsViewController(with weatherData: WeatherData, delegate: WeatherDetailsViewDelegate)
}

class CitiesListViewRouter: CitiesListViewRouterProtocol {
    private let weatherDetailsIdentifier = "weatherDetails"
    private weak var citiesListViewController: CitiesListViewController!
    private weak var weatherDetailsViewDelegate: WeatherDetailsViewDelegate!
    private var detailedWeatherData: WeatherData!
    
    init(citiesListViewController: CitiesListViewController) {
        self.citiesListViewController = citiesListViewController
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == weatherDetailsIdentifier {
            if let viewController = segue.destination as? WeatherDetailsViewController {
                let useCase = DataLayer.UseCaseProvider().makeWeatherDataUseCase()
                viewController.presenter = WeatherDetailsPresenter(view: viewController, useCase: useCase, weatherData: detailedWeatherData, delegate: weatherDetailsViewDelegate)
            }
        }
    }
    
    func presentWeatherDetailsViewController(with weatherData: WeatherData, delegate: WeatherDetailsViewDelegate) {
        self.detailedWeatherData = weatherData
        self.weatherDetailsViewDelegate = delegate
        citiesListViewController.performSegue(withIdentifier: weatherDetailsIdentifier, sender: nil)
    }
}
