//
//  WeatherDetailsViewController.swift
//  SimpleWeatherApp
//
//  Created by Александр Камышев on 13.11.2020.
//

import UIKit
import Domain

class WeatherDetailsViewController: UIViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    var weatherData: WeatherData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityNameLabel.text = weatherData.name
        weatherDescriptionLabel.text = "Temp: \(weatherData.main.temp) °C\nMax temp: \(weatherData.main.tempMax) °C\nMin temp: \(weatherData.main.tempMin) °C"
        navigationItem.title = "Weather in \(weatherData.name)"
    }
}
