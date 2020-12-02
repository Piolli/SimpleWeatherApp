//
//  CityCellView.swift
//  SimpleWeatherApp
//
//  Created by Alexandr Kamyshev on 30.11.2020.
//

import Foundation
import UIKit

protocol CityCellView {
    func display(text: String)
    func display(leadingImage: UIImage)
}

class CityTableViewCell: UITableViewCell, CityCellView {
    
    static let identifier = "cell"
    
    init() {
        super.init(style: .default, reuseIdentifier: CityTableViewCell.identifier)
        self.accessoryType = .disclosureIndicator
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame.origin.x = self.frame.origin.x + 16
    }
    
    func display(text: String) {
        textLabel?.text = text
    }
    
    func display(leadingImage: UIImage) {
        imageView?.image = leadingImage
    }
}
