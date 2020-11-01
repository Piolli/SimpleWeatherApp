//
//  File.swift
//  
//
//  Created by Александр Камышев on 28.10.2020.
//

import Foundation

public enum AppError: Error {
    
    // MARK: - Network
    case networkWith(statusCode: Int)
    case networkWith(Error, statusCode: Int)
    case networkDataParsing
    
    // MARK: - Local storage
    case cityNotFound
    case localStorage
    case unknown
    
}
