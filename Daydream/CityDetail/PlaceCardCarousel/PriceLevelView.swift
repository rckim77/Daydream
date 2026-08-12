//
//  PriceLevelView.swift
//  Daydream
//
//  Created by Ray Kim on 10/16/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct PriceLevelView: View {
    
    let priceLevel: PriceLevel
    
    var body: some View {
        dollarView
            .glassEffect()
            .clipShape(Capsule())
    }
    
    private var dollarView: some View {
        HStack(spacing: 2) {
            if priceLevel == .inexpensive {
                Image(systemName: "dollarsign").bold()
            } else if priceLevel == .moderate {
                Image(systemName: "dollarsign").bold()
                Image(systemName: "dollarsign").bold()
            } else if priceLevel == .expensive {
                Image(systemName: "dollarsign").bold()
                Image(systemName: "dollarsign").bold()
                Image(systemName: "dollarsign").bold()
            } else if priceLevel == .veryExpensive {
                Image(systemName: "dollarsign").bold()
                Image(systemName: "dollarsign").bold()
                Image(systemName: "dollarsign").bold()
                Image(systemName: "dollarsign").bold()
            }
        }
        .padding(6)
    }
}
