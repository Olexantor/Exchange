//
//  Box.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

class Box<T> {
    typealias Listener = (T) -> ()
    private var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(value)
    }
    
    init(_ value: T) {
        self.value = value
    }
}
