//
//  NetworkManager.swift
//  Exchange
//
//  Created by Александр on 08.03.2022.
//
import Alamofire
import Foundation

enum fetchErrors: Error {
    case missingData
}

class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchCurrencyList(completion: @escaping (Result<ExchangedRates, Error>) -> Void) {
        AF.request(currencyUrl, headers: headers).validate().response { response in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else {
                        completion(.failure(fetchErrors.missingData))
                        return
                    }
                    let currencyList = try JSONDecoder()
                        .decode(ExchangedRates.self, from: data)
                    completion(.success(currencyList))
                }
                catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private init() {}
}
