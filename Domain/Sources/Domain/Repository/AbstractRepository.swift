//
//  File.swift
//  
//
//  Created by Александр Камышев on 30.10.2020.
//

import Foundation

open class Repository<T> {
    
    public init() {
        
    }
    
    open func queryAll(_ completion: @escaping (Result<[T], AppError>) -> Void) {
        fatalError("queryAll(_:) has not been implemented")
    }
    
    /// Queries data from repository
    /// - Parameters:
    ///   - predicate: specifies format with variables and operators
    ///   - variables: substituion values for predicate format
    ///   - completion: result block
    ///  For predicate call method `predicate.withSubstitutionVariables(variables)` for variables substitution
    open func query(with predicate: NSPredicate, variables: [String: Any], _ completion: @escaping (Result<[T], AppError>) -> Void) {
        fatalError("query(with:_:) has not been implemented")
    }
    
    open func save(entity: T, _ completion: @escaping (Result<Void, AppError>) -> Void) {
        fatalError("save(entiry:_:) has not been implemented")
    }
    
    open func delete(entity: T, _ completion: @escaping (Result<Void, AppError>) -> Void) {
        fatalError("delete(entiry:_:) has not been implemented")
    }
    
}
    

