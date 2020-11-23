//
//  File.swift
//  
//
//  Created by Alexandr Kamyshev on 22.11.2020.
//

import Foundation

public protocol DefaultValueProvider {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

public enum DefaultValue {
    
    public typealias False = Wrapper<Providers.False>
    
    public enum Providers {
        public enum False: DefaultValueProvider {
            public static var defaultValue: Bool { false }
        }
    }
    
    @propertyWrapper
    public struct Wrapper<Provider: DefaultValueProvider> {
        public var wrappedValue = Provider.defaultValue
        
        public init() { }
    }
}

extension DefaultValue.Wrapper: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Provider.Value.self)
    }
}

extension DefaultValue.Wrapper: Equatable where Provider.Value: Equatable { }
extension DefaultValue.Wrapper: Encodable where Provider.Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: DefaultValue.Wrapper<T>.Type, forKey key: Key) throws -> DefaultValue.Wrapper<T> {
        return try decodeIfPresent(type, forKey: key) ?? .init()
    }
}
