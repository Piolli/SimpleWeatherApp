//
//  Extensions.swift
//  SimpleWeatherApp
//
//  Created by Alexandr Kamyshev on 20.11.2020.
//

import Foundation
import UIKit

extension UIViewController {
    func show(error: Error, okCompletion: (() -> Void)? = nil) {
        let dialog = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            okCompletion?()
        }
        dialog.addAction(okAction)
        present(dialog, animated: true, completion: nil)
        
    }
}
