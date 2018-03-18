//
//  Colors.swift
//  Daydream
//
//  Created by Raymond Kim on 2/25/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit

enum Color {
    
    case customPurple
    case customRed
    case custom(hexString: String, alpha: Double)
    
    func withAlpha(_ alpha: Double) -> UIColor {
        return self.value.withAlphaComponent(CGFloat(alpha))
    }
}

extension Color {
    
    var value: UIColor {
        var instanceColor: UIColor = .clear
        
        switch self {
        case .customPurple:
            instanceColor = UIColor(hexString: "#756C83")
        case .customRed:
            instanceColor = UIColor(hexString: "#F38181")
        case .custom(let hexValue, let opacity):
            instanceColor = UIColor(hexString: hexValue).withAlphaComponent(CGFloat(opacity))
        }
        
        return instanceColor
    }
    
}
