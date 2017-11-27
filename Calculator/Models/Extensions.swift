//
//  Extensions.swift
//  Calculator
//
//  Created by Christopher Smith on 11/27/17.
//  Copyright © 2017 Christopher Smith. All rights reserved.
//

import Foundation

extension Double {
    
    var isWholeNumber: Bool {
        return self.truncatingRemainder(dividingBy: 1) == 0
    }
}
