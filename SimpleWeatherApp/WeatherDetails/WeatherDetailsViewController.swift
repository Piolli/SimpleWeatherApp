//
//  WeatherDetailsViewController.swift
//  SimpleWeatherApp
//
//  Created by Александр Камышев on 13.11.2020.
//

import UIKit
import Domain

protocol WeatherDetailsViewDelegate: class {
    func showError(_ error: AppError)
    func setCityName(_ text: String)
    func setNavigationItemTitle(_ text: String)
    func setWeatherDescription(_ text: String)
    func setFavoriteButtonImage(_ image: UIImage)
}

protocol WeatherDetailsPresenterProtocol: class {
    func viewDidLoad()
    func updateFavoriteValue(completion: @escaping (_ newValue: Bool) -> Void)
}

protocol WeatherDetailsViewControllerDelegate: class {
    func weatherDataWasSetFavorited(value: Bool)
}

class WeatherDetailsViewController: UIViewController {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    weak var delegate: WeatherDetailsViewControllerDelegate?
    var presenter: WeatherDetailsPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    @IBAction func favoriteButtonWasTapped(_ sender: Any) {
        presenter.updateFavoriteValue { [weak self] (newValue) in
            self?.delegate?.weatherDataWasSetFavorited(value: newValue)
        }
    }
}

extension WeatherDetailsViewController: WeatherDetailsViewDelegate {
    func showError(_ error: AppError) {
        self.show(error: error)
    }
    
    func setCityName(_ text: String) {
        cityNameLabel.text = text
    }
    
    func setNavigationItemTitle(_ text: String) {
        navigationItem.title = text
    }
    
    func setWeatherDescription(_ text: String) {
        weatherDescriptionLabel.text = text
    }
    
    func setFavoriteButtonImage(_ image: UIImage) {
        navigationItem.rightBarButtonItem?.image = image
    }
}
