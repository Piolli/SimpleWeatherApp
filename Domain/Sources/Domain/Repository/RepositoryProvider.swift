//
//  File.swift
//  
//
//  Created by Александр Камышев on 30.10.2020.
//

import Foundation

public protocol RepositoryProvider {
    associatedtype T
    func makeRepository() -> Repository<T>
    
}
