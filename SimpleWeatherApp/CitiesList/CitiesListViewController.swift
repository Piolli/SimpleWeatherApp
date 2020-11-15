//
//  CitiesListViewController.swift
//  SimpleWeatherApp
//
//  Created by Александр Камышев on 12.11.2020.
//

import UIKit
import Domain
import DataLayer

protocol CitiesListViewDelegate: class {
    func showCities(_ cities: [WeatherData])
    func showError(_ error: AppError)
    func addWeatherData(_ weatherData: Domain.WeatherData)
}

class CitiesListViewController: UIViewController {
    let cellIdentifier = "cell"
    let weatherDetailsIdentifier = "weatherDetails"
    lazy var refreshControl = UIRefreshControl()
    var weatherDataList: [Domain.WeatherData] = []
    var presenter: CitiesListPresenter!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        ///#Add from DI container
        let useCase = DataLayer.UseCaseProvider().makeWeatherDataUseCase()
        presenter = CitiesListPresenter(delegate: self, useCase: useCase)
        presenter.loadLocalStorageCities()
    }
    
    @objc func handleRefreshControl() {
        presenter.updateAllWeatherData {
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
            }
        }
    }

    @IBAction func addBarButtonWasTapped(_ sender: UIBarButtonItem) {
        let dialog = UIAlertController(title: "Add city to list", message: nil, preferredStyle: .alert)
        dialog.addTextField { (textField) in
            textField.placeholder = "Enter city's name"
        }
        let loadAction = UIAlertAction(title: "Load", style: .default) { [unowned self] (action) in
            let inputField = dialog.textFields![0]
            guard let inputText = inputField.text else {
                return
            }
            self.presenter.loadCity(inputText)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        dialog.addAction(cancelAction)
        dialog.addAction(loadAction)
        present(dialog, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == weatherDetailsIdentifier {
            guard let viewController = segue.destination as? WeatherDetailsViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
            let weatherData = weatherDataList[indexPath.row]
            viewController.weatherData = weatherData
        }
    }
}

//MARK: - CitiesListViewDelegate
extension CitiesListViewController: CitiesListViewDelegate {
    
    func showError(_ error: AppError) {
        let dialog = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        dialog.addAction(okAction)
        present(dialog, animated: true, completion: nil)
    }
    
    func showCities(_ cities: [WeatherData]) {
        weatherDataList.removeAll()
        weatherDataList.append(contentsOf: cities)
        tableView.reloadData()
    }
    
    func addWeatherData(_ weatherData: Domain.WeatherData) {
        weatherDataList.append(weatherData)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: weatherDataList.count-1, section: 0)], with: .left)
        tableView.endUpdates()
    }
    
}

// MARK: - UITableViewDataSource
extension CitiesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = "\(weatherDataList[indexPath.row].name) - \(weatherDataList[indexPath.row].id)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CitiesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: weatherDetailsIdentifier, sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
