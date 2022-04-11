//
//  DataManagerType.swift
//  Exchange
//
//  Created by Александр Николаев on 31.03.2022.
//

import Foundation
import RxSwift

protocol DataManagerType {
    func save(currency: [String])
    func loadCurrency() -> Single<[String]>
    func deleteCurrency()
}
