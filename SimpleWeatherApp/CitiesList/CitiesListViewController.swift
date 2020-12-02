//
//  CitiesListViewController.swift
//  SimpleWeatherApp
//
//  Created by Александр Камышев on 12.11.2020.
//

import UIKit
import Domain
import DataLayer

protocol CitiesListView: class {
    func showError(_ error: AppError)
    func setRefreshing(value: Bool)
    func refreshCitiesView()
    func showAddCityDialog()
    func insertRow(at indexPath: IndexPath)
    func removeRow(at indexPath: IndexPath)
}

class CitiesListViewController: UIViewController {
    
    var presenter: CitiesListPresenterProtocol!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CityTableViewCell.self, forCellReuseIdentifier: CityTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        CitiesListConfigurator().configure(citiesListViewController: self)
        presenter.viewDidLoad()
    }
    
    func setRefreshing(value: Bool) {
        if value {
            tableView.refreshControl!.beginRefreshing()
        } else {
            tableView.refreshControl!.endRefreshing()
        }
    }
    
    @objc func handleRefreshControl() {
        presenter.updateAllWeatherData()
    }

    @IBAction func addBarButtonWasTapped(_ sender: UIBarButtonItem) {
        presenter.addCityButtonWasPressed()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        presenter.router.prepare(for: segue, sender: sender)
    }
}

//MARK: - CitiesListViewDelegate
extension CitiesListViewController: CitiesListView {
    func refreshCitiesView() {
        tableView.reloadData()
    }
    
    func showError(_ error: AppError) {
        self.show(error: error) {
            self.setRefreshing(value: false)
        }
    }
    
    func showAddCityDialog() {
        let vc = UIAlertController.oneTextFieldDialog(title: "Add city", message: "City weather will load from server", actionTitle: "Add", textFieldPlaceholder: "Write city's name") { (cityName) in
            self.presenter.addCity(cityName)
        }
        present(vc, animated: true, completion: nil)
    }
    
    func insertRow(at indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func removeRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension CitiesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfCities
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.identifier, for: indexPath) as! CityTableViewCell
        presenter.configureCell(cell, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CitiesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] (action, view, comp)  in
            guard let self = self else {
                return
            }
            self.presenter.removeWeatherData(at: indexPath)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
