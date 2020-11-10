//
//  File.swift
//  
//
//  Created by Александр Камышев on 09.11.2020.
//

import Foundation
import Domain
import RealmSwift

public class RepositoryProvider: Domain.RepositoryProvider {
    
    let configuration: Realm.Configuration
    
    public init(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration) {
        self.configuration = configuration
    }
    
    public func makeRepository() -> Repository<WeatherData> {
        return RealmRepository(configuration: configuration)
    }
}
