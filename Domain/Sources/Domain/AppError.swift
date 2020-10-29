//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation

public enum AppError: Error, Equatable {
    case networkError
    case cityNotFoundError(String)
    case localStorageError
    case unknown
}
