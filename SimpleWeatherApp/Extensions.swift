//
//  Extensions.swift
//  SimpleWeatherApp
//
//  Created by Alexandr Kamyshev on 20.11.2020.
//

import Foundation
import UIKit

extension UIViewController {
    func show(error: Error) {
        let dialog = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        dialog.addAction(okAction)
        present(dialog, animated: true, completion: nil)
    }
}
