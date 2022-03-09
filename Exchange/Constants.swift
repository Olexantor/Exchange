//
//  Constants.swift
//  Exchange
//
//  Created by Александр on 08.03.2022.
//
import Alamofire
import Foundation

let headers: HTTPHeaders = [
    "x-rapidapi-host": "currency-converter5.p.rapidapi.com",
    "x-rapidapi-key": "f96847c424msh3226f07e3f2ade4p1464a8jsn93f99a3b39e5"
]

let currencyUrl = "https://currency-converter5.p.rapidapi.com/currency/list"
let convertUrl = "https://currency-converter5.p.rapidapi.com/currency/convert?from="
