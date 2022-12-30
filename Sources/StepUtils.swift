//
//  File.swift
//  
//
//  Created by Reed Esau on 12/30/22.
//

import Foundation


public func isFractional(value: Float) -> Bool {
    value.truncatingRemainder(dividingBy: 1) >= 0.1
}
