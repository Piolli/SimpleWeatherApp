//
//  File.swift
//  
//
//  Created by Александр Камышев on 31.10.2020.
//

import Foundation
import Domain
import Alamofire

class AFNetwork: Network {
    
    let endpoint: String
    let session: Alamofire.Session
    let apiKey: String
    
    init(endpoint: String, apiKey: String, session: Alamofire.Session = .default) {
        self.endpoint = endpoint
        self.session = session
        self.apiKey = apiKey
    }
    
    func fetchWeatherData(cityName: String, completion: @escaping (Result<WeatherData, AppError>) -> Void) {
        let params = [
            // make as default for each request
            "appid": apiKey,
            "units": "metric",
            
            "q": cityName,
        ]
        
        let serializer = DecodableObjectSerializer<WeatherData>()
        session.request(endpoint.appending("/weather"), method: .get, parameters: params)
            .response(responseSerializer: serializer) { (response) in
                let result = response.result
                    .mapError{ AppError.networkWith($0, statusCode: $0.asAFError?.responseCode ?? 0) }
                completion(result)
        }
    }
}

struct DecodableObjectSerializer<T: Decodable>: DataResponseSerializerProtocol {
    typealias SerializedObject = T
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        if let error = error {
            throw AppError.networkWith(error, statusCode: error.asAFError?.responseCode ?? 0)
        }
        guard let data = data else {
            throw AppError.networkWith(statusCode: (response?.statusCode ?? 0))
        }
        do {
            let parsedObject = try JSONDecoder().decode(T.self, from: data)
            return parsedObject
        } catch {
            throw AppError.networkDataParsing
        }
    }
}
