//
//  Images.swift
//  SimpleWeatherApp
//
//  Created by Alexandr Kamyshev on 20.11.2020.
//

import Foundation
import UIKit

enum Images {
    static func getStarImageFor(value: Bool) -> UIImage {
        return value ? UIImage(named: "star-fill")! : UIImage(named: "star-line")!
    }
}
