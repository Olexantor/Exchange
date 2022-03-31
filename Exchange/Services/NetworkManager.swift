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
    
    func fetchCurrencyList(completion: @escaping (
        Result<CurrenciesList,
        Error>
    ) -> Void) {
        AF.request(Constants.currencyUrl).validate().response { response in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else {
                        completion(.failure(fetchErrors.missingData))
                        return
                    }
                    let currencyList = try JSONDecoder()
                        .decode(CurrenciesList.self, from: data)
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
    
    func fetchExchangeRate(for base: String, and completion: @escaping (
        Result<ExchangeRate,
        Error>
    ) -> Void) {
        let url = Constants.convertUrl+base
        AF.request(url).validate().response { response in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else {
                        completion(.failure(fetchErrors.missingData))
                        return
                    }
                    let currencyList = try JSONDecoder()
                        .decode(CurrenciesList.self, from: data)
                    guard let rate = ExchangeRate(data: currencyList) else { return }
                    completion(.success(rate))
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
