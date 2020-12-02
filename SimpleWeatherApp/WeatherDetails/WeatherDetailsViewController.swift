//
//  WeatherDetailsViewController.swift
//  SimpleWeatherApp
//
//  Created by Александр Камышев on 13.11.2020.
//

import UIKit
import Domain

protocol WeatherDetailsView: class {
    func showError(_ error: AppError)
    func setCityName(_ text: String)
    func setNavigationItemTitle(_ text: String)
    func setWeatherDescription(_ text: String)
    func setFavoriteButtonImage(_ image: UIImage)
}

protocol WeatherDetailsPresenterProtocol: class {
    func viewDidLoad()
    func updateFavoriteValue()
}

protocol WeatherDetailsViewDelegate: class {
    func weatherDataWasSetFavorited(value: Bool, id: Int)
}

class WeatherDetailsViewController: UIViewController {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    weak var delegate: WeatherDetailsViewDelegate?
    var presenter: WeatherDetailsPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    @IBAction func favoriteButtonWasTapped(_ sender: Any) {
        presenter.updateFavoriteValue()
    }
}

extension WeatherDetailsViewController: WeatherDetailsView {
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
