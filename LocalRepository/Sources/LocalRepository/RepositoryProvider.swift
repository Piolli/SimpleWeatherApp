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
    
    public convenience init() {
        if var directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.sanyakam.SimpleWeatherApp.SharedData") {
            directory.appendPathComponent("db.realm", isDirectory: true)
            let config = Realm.Configuration(fileURL: directory)
            self.init(configuration: config)
        } else {
            self.init(configuration: Realm.Configuration.defaultConfiguration)
        }
    }
    
    public init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }
    
    public func makeRepository() -> Repository<WeatherData> {
        return RealmRepository(configuration: configuration)
    }
}
