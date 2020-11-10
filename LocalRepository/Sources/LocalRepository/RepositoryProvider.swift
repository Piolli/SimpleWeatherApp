//
//  File.swift
//  
//
//  Created by Александр Камышев on 09.11.2020.
//

import Foundation
import Domain
import RealmSwift

class RepositoryProvider: Domain.RepositoryProvider {
    func makeRepository() -> Repository<WeatherData> {
        let configuration = Realm.Configuration.defaultConfiguration
        return RealmRepository(configuration: configuration)
    }
}
