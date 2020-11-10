//
//  File.swift
//  
//
//  Created by Александр Камышев on 09.11.2020.
//

import Foundation
import Domain
import RealmSwift

class RealmRepository<T: RealmRepresentable>: Repository<T> where T == T.RealmType.DomainType, T.RealmType: Object {
    
    let configuration: Realm.Configuration
    
    private var realm: Realm {
        return try! Realm(configuration: self.configuration)
    }

    init(configuration: Realm.Configuration = .defaultConfiguration) {
        self.configuration = configuration
    }
    
    override func queryAll(_ completion: @escaping (Result<[T], AppError>) -> Void) {
        let objects = realm.objects(T.RealmType.self)
        complete(objects, completion)
    }
    
    override func query(with predicate: NSPredicate, variables: [String : Any], _ completion: @escaping (Result<[T], AppError>) -> Void) {
        let predicate = predicate.withSubstitutionVariables(variables)
        let objects = realm.objects(T.RealmType.self)
            .filter(predicate)
        complete(objects, completion)
    }
    
    fileprivate func complete(_ objects: Results<T.RealmType>, _ completion: (Result<[T], AppError>) -> Void) {
        if objects.count == 0 {
            completion(.failure(.localStorageIsEmpty))
        } else {
            completion(.success(Array(objects).map{$0.asDomain()}))
        }
    }
    
    override func save(entity: T, _ completion: @escaping (Result<Void, AppError>) -> Void) {
        do {
            try realm.write {
                realm.add(entity.asRealm(), update: .all)
                completion(.success(()))
            }
        } catch {
            completion(.failure(.localStorageWith(error)))
        }
    }
    
    override func delete(entity: T, _ completion: @escaping (Result<Void, AppError>) -> Void) {
        guard let object = realm.object(ofType: T.RealmType.self, forPrimaryKey: entity.id) else {
            completion(.failure(.localStorageObjectNotExisted))
            return
        }
        do {
            try realm.write {
                realm.delete(object)
                completion(.success(()))
            }
        } catch {
            completion(.failure(.localStorageWith(error)))
        }
    }
    
}
