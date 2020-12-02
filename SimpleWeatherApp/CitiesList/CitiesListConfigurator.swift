//
//  CitiesListConfigurator.swift
//  SimpleWeatherApp
//
//  Created by Alexandr Kamyshev on 01.12.2020.
//

import Foundation
import DataLayer

class CitiesListConfigurator {
    
    func configure(citiesListViewController: CitiesListViewController) {
        let useCase = DataLayer.UseCaseProvider().makeWeatherDataUseCase()
        let router = CitiesListViewRouter(citiesListViewController: citiesListViewController)
        let presenter = CitiesListPresenter(view: citiesListViewController, useCase: useCase, router: router)
        citiesListViewController.presenter = presenter
    }
    
}
