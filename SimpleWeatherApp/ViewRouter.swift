//
//  ViewRouter.swift
//  SimpleWeatherApp
//
//  Created by Alexandr Kamyshev on 30.11.2020.
//

import Foundation
import UIKit

protocol ViewRouter {
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

extension ViewRouter {
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
