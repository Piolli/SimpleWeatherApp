//
//  File.swift
//  
//
//  Created by Александр Камышев on 04.11.2020.
//

import Foundation

protocol DomainConvertible {
    associatedtype DomainType: RealmRepresentable
    
    func asDomain() -> DomainType
}
