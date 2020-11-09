//
//  File.swift
//  
//
//  Created by Александр Камышев on 04.11.2020.
//

import Foundation
import RealmSwift

protocol RealmRepresentable {
    associatedtype RealmType: DomainConvertible
    
    var id: Int { get }
    
    func asRealm() -> RealmType
}
