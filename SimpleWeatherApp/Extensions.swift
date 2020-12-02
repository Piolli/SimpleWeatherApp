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

extension UIAlertController {
    static func oneTextFieldDialog(title: String, message: String, actionTitle: String, textFieldPlaceholder: String, completion: @escaping (String) -> Void) -> UIAlertController {
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        dialog.addTextField { (textField) in
            textField.placeholder = textFieldPlaceholder
        }
        let loadAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            let inputField = dialog.textFields![0]
            guard let inputText = inputField.text else {
                return
            }
            completion(inputText)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        dialog.addAction(cancelAction)
        dialog.addAction(loadAction)
        return dialog
    }
}
